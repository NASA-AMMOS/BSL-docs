#[[
Copyright (c) 2023-2026 The Johns Hopkins University Applied Physics
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
file(GLOB ADOC_EXTRAS "images/*.gv" "images/*.puml")


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

find_program(JAVA_BIN java REQUIRED)
find_program(XMLSTARLET xmlstarlet REQUIRED)
set(HTML_XSLT "${CMAKE_CURRENT_SOURCE_DIR}/xhtml-opts.xsl")
set(MANUAL_CSS "${CMAKE_CURRENT_SOURCE_DIR}/manual.css")
set(DOCBOOK_CSS_FILES
    "docbook.css" "docbook-paged.css"
    "docbook-toc.css" "pygments.css"
)
set(DOCBOOK_JS_FILES "copy-verbatim.js" "persistent-toc.js")
set(OUT_MANUAL_CSS "html/css/manual.css")
set(OUT_HTML "html/index.html")

configure_file(
    "xml-catalog.xml.in"
    "xml-catalog.xml"
    @ONLY
)
add_custom_command(
    OUTPUT ${OUT_HTML}
    DEPENDS ${OUT_DBOOK} "xml-catalog.xml" ${HTML_XSLT}
    COMMAND
        ${JAVA_BIN} -jar ${xsltng_JAR}
        -catalog:xml-catalog.xml -xsl:${HTML_XSLT}
        -o:${OUT_HTML} ${OUT_DBOOK}
)
# Place needed files into HTML tree
add_custom_command(
    OUTPUT ${OUT_MANUAL_CSS}
    DEPENDS ${MANUAL_CSS}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MANUAL_CSS} ${OUT_MANUAL_CSS}
    COMMENT "Copy manual.css"
)
set(OUT_DOCBOOK_FILES "")
foreach(FILENAME ${DOCBOOK_CSS_FILES})
  set(INPATH "${xsltng_SOURCE_DIR}/resources/css/${FILENAME}")
  set(OUTPATH "html/css/${FILENAME}")
  add_custom_command(
      OUTPUT ${OUTPATH}
      DEPENDS ${INPATH}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${INPATH} ${OUTPATH}
      COMMENT "Copy css/${FILENAME}"
  )
  list(APPEND OUT_DOCBOOK_FILES ${OUTPATH})
endforeach()
foreach(FILENAME ${DOCBOOK_JS_FILES})
  set(INPATH "${xsltng_SOURCE_DIR}/resources/js/${FILENAME}")
  set(OUTPATH "html/js/${FILENAME}")
  add_custom_command(
      OUTPUT ${OUTPATH}
      DEPENDS ${INPATH}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${INPATH} ${OUTPATH}
      COMMENT "Copy js/${FILENAME}"
  )
  list(APPEND OUT_DOCBOOK_FILES ${OUTPATH})
endforeach()
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
        ${OUT_HTML} ${OUT_MANUAL_CSS} ${OUT_DOCBOOK_FILES} ${PROJECT_NAME}-img-html
)
install(
    DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html"
    DESTINATION ${PROJECT_NAME}
)

if(XMLSTARLET AND ASPELL)
    # spellcheck on HTML output
    set(DICTIONARY_TXT "${CMAKE_CURRENT_SOURCE_DIR}/dictionary.txt")
    set(SPELLCHECK_XSL "${CMAKE_CURRENT_SOURCE_DIR}/spellcheck.xsl")
    add_custom_command(
        OUTPUT "dictionary.cwl"
        DEPENDS "${DICTIONARY_TXT}"
        COMMAND cat "${DICTIONARY_TXT}" |
            ${ASPELL} --lang=en create master "./dictionary.cwl"
    )
    add_custom_command(
        OUTPUT "misspelling.txt"
        DEPENDS
            "${OUT_HTML}" "${SPELLCHECK_XSL}" "dictionary.cwl"
        COMMAND
            ${XMLSTARLET} tr "${SPELLCHECK_XSL}" "${OUT_HTML}" |
            ${ASPELL} --mode=html --lang=EN_US --extra-dicts=./dictionary.cwl list |
            sort -u >"misspelling.txt"
    )
    add_custom_command(
        OUTPUT "misspelling-ctx.txt"
        DEPENDS
            "${OUT_HTML}" "misspelling.txt"
        COMMAND
            ${XMLSTARLET} fo "${OUT_HTML}" |
            grep --file "misspelling.txt" >"misspelling-ctx.txt" || true
    )
    add_custom_target(
        ${PROJECT_NAME}-misspelling ALL
        DEPENDS "misspelling.txt" "misspelling-ctx.txt"
    )
endif(XMLSTARLET AND ASPELL)

# PDF document output
find_program(DBLATEX dblatex REQUIRED)
if(DBLATEX)
    set(PDF_STYLE "${CMAKE_CURRENT_SOURCE_DIR}/manual.sty")
    set(PDF_XSLT "${CMAKE_CURRENT_SOURCE_DIR}/pdf-opts.xsl")
    set(OUT_PDF "manual.pdf")
    add_custom_command(
        OUTPUT ${OUT_PDF}
        DEPENDS ${OUT_DBOOK} ${PDF_STYLE} ${PDF_XSLT} ${PROJECT_NAME}-img-bin
        COMMAND
            ${DBLATEX}
            --texstyle=${PDF_STYLE} --xsl-user=${PDF_XSLT}
            -o ${OUT_PDF} ${OUT_DBOOK}
    )
    add_custom_target(
        ${PROJECT_NAME}-pdf ALL
        DEPENDS ${OUT_PDF}
    )
    install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/${OUT_PDF}"
        RENAME "bsl-product-guide.pdf"
        DESTINATION ${PROJECT_NAME}
    )
endif(DBLATEX)
