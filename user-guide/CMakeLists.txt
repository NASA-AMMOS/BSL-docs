#[[
Copyright (c) 2023-2025 The Johns Hopkins University Applied Physics
Laboratory LLC.

This file is part of the Bundle Protocol Security Library (BSL).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

This work was performed for the Jet Propulsion Laboratory, California
Institute of Technology, sponsored by the United States Government under
the prime contract 80NM0018D0004 between the Caltech and NASA under
subcontract 1700763.
]]
cmake_minimum_required(VERSION 3.16)
get_filename_component(DIRNAME ${CMAKE_CURRENT_LIST_DIR} NAME)
# No compiler checks
project(${DIRNAME} VERSION 0 LANGUAGES )


# File paths
set(ADOC_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/manual.adoc")
set(ADOC_EXTRAS 
    "static/bsl-interaction-points.gv"
    "static/bpa-associations.puml"
    "static/bsl-breakdown.puml"
    "static/bundle-workflow.puml"
    "static/secop-associations.puml"
)


find_program(ASCIIDOC asciidoctor REQUIRED)
find_program(ASPELL aspell)
if(NOT ASPELL)
    message(FATAL_ERROR "Program aspell not found")
endif()

set(OUT_DOCINFO "docinfo.xml")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/${OUT_DOCINFO}.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/${OUT_DOCINFO}"
    @ONLY
)
set(OUT_DBOOK "${CMAKE_CURRENT_BINARY_DIR}/manual.docbook.xml")
add_custom_command(
    OUTPUT ${OUT_DBOOK}
    DEPENDS ${ADOC_SOURCE} ${ADOC_EXTRAS} ${OUT_DOCINFO}
    COMMAND
        ${ASCIIDOC} -v -r asciidoctor-diagram
        --base-dir ${CMAKE_CURRENT_SOURCE_DIR}
        --destination-dir ${CMAKE_CURRENT_BINARY_DIR}
        -o ${OUT_DBOOK}
    ${ADOC_SOURCE}
)
# Place source images into build directory
set(INSTALL_IMGS ${CMAKE_CURRENT_SOURCE_DIR}/install_imgs.sh)
add_custom_target(
    ${PROJECT_NAME}-img-bin
    DEPENDS ${INSTALL_IMGS} ${OUT_DBOOK}
    COMMAND
        ${INSTALL_IMGS} ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR} ${OUT_DBOOK}
)

set(HTML_XSLT "${CMAKE_CURRENT_SOURCE_DIR}/xhtml-opts.xsl")
set(MANUAL_CSS "${CMAKE_CURRENT_SOURCE_DIR}/manual.css")
find_program(XMLSTARLET xmlstarlet REQUIRED)
set(OUT_HTML "html/index.html")
set(OUT_DOCBOOK_CSS "html/docbook.css")
set(OUT_MANUAL_CSS "html/manual.css")
add_custom_command(
    OUTPUT "html"
    COMMAND ${CMAKE_COMMAND} -E make_directory html
)
add_custom_command(
    OUTPUT ${OUT_HTML}
    BYPRODUCTS ${OUT_DOCBOOK_CSS}
    DEPENDS ${OUT_DBOOK} ${HTML_XSLT} "html"
    WORKING_DIRECTORY html
    COMMAND ${XMLSTARLET} tr ${HTML_XSLT} ${OUT_DBOOK} >index.html
)
# Place needed files into HTML tree
add_custom_command(
    OUTPUT ${OUT_MANUAL_CSS}
    DEPENDS ${MANUAL_CSS}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MANUAL_CSS} ${OUT_MANUAL_CSS}
    COMMENT "Copy manual.css"
)
add_custom_target(
    ${PROJECT_NAME}-img-html
    DEPENDS ${INSTALL_IMGS} ${OUT_HTML} ${PROJECT_NAME}-img-bin
    COMMAND
        ${INSTALL_IMGS} ${CMAKE_CURRENT_BINARY_DIR}
        "${CMAKE_CURRENT_BINARY_DIR}/html"
)
add_custom_target(
    ${PROJECT_NAME}-html ALL
    DEPENDS
        ${OUT_HTML} ${OUT_DOCBOOK_CSS} ${OUT_MANUAL_CSS} ${PROJECT_NAME}-img-html
)
install(
    DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html"
    DESTINATION ${PROJECT_NAME}
)


# spellcheck on HTML output
set(DICTIONARY_TXT "${CMAKE_CURRENT_SOURCE_DIR}/dictionary.txt")
set(SPELLCHECK_XSL "${CMAKE_CURRENT_SOURCE_DIR}/spellcheck.xsl")
set(MISSPELLING_TXT "misspelling.txt")
add_custom_command(
    OUTPUT "dictionary.cwl"
    DEPENDS "${DICTIONARY_TXT}"
    COMMAND cat "${DICTIONARY_TXT}" |
        ${ASPELL} --lang=en create master "./dictionary.cwl"
)
add_custom_command(
    OUTPUT "${MISSPELLING_TXT}"
    DEPENDS "${OUT_HTML}" "${SPELLCHECK_XSL}" "dictionary.cwl"
    COMMAND ${XMLSTARLET} tr "${SPELLCHECK_XSL}" "${OUT_HTML}" |
        ${ASPELL} --mode=html --lang=EN_US --extra-dicts=./dictionary.cwl list |
        sort | uniq > "${MISSPELLING_TXT}"
)
add_custom_target(
    ${PROJECT_NAME}-misspelling ALL
    DEPENDS "${MISSPELLING_TXT}"
    COMMAND cat "${MISSPELLING_TXT}"
    # success means file is present and empty
    COMMAND test -f "${MISSPELLING_TXT}" -a ! -s "${MISSPELLING_TXT}"
    COMMENT "Checking ${MISSPELLING_TXT}"
)


# PDF document output
find_program(DBLATEX dblatex REQUIRED)
set(PDF_XSLT "${CMAKE_CURRENT_SOURCE_DIR}/pdf-opts.xsl")
set(OUT_PDF "manual.pdf")
add_custom_command(
    OUTPUT ${OUT_PDF}
    DEPENDS ${OUT_DBOOK} ${PDF_XSLT} ${PROJECT_NAME}-img-bin
    COMMAND ${DBLATEX} -o ${OUT_PDF} --xsl-user=${PDF_XSLT} ${OUT_DBOOK}
)
add_custom_target(
    ${PROJECT_NAME}-pdf ALL
    DEPENDS ${OUT_PDF}
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/${OUT_PDF}"
    DESTINATION ${PROJECT_NAME}
#  RENAME "BSL User Guide v${PROJECT_VERSION}.pdf"
)
