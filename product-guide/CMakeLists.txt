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


find_program(ASCIIDOC asciidoctor REQUIRED)
set(OUT_DOCINFO "docinfo.xml")
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/${OUT_DOCINFO}.in"
  "${CMAKE_CURRENT_SOURCE_DIR}/${OUT_DOCINFO}"
  @ONLY
)
set(OUT_DBOOK "manual.docbook.xml")
add_custom_command(
  OUTPUT ${OUT_DBOOK}
  DEPENDS ${ADOC_SOURCE} ${OUT_DOCINFO}
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
  COMMAND ${INSTALL_IMGS} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} ${OUT_DBOOK}
)

find_program(XSLTPROC xsltproc REQUIRED)
set(HTML_XSLT "${CMAKE_CURRENT_SOURCE_DIR}/xhtml-opts.xsl")
find_program(XMLSTARLET xmlstarlet REQUIRED)
set(OUT_HTML "html/index.html")
set(OUT_CSS "html/docbook.css")
add_custom_command(
  OUTPUT ${OUT_HTML}
  BYPRODUCTS ${OUT_CSS}
  DEPENDS ${OUT_DBOOK} ${HTML_XSLT}
  COMMAND ${XSLTPROC} -o ${OUT_HTML} ${HTML_XSLT} ${OUT_DBOOK}
)
# Place needed images into HTML tree
add_custom_target(
  ${PROJECT_NAME}-img-html
  DEPENDS ${INSTALL_IMGS} ${OUT_HTML} ${PROJECT_NAME}-img-bin
  COMMAND ${INSTALL_IMGS} ${CMAKE_CURRENT_BINARY_DIR} "${CMAKE_CURRENT_BINARY_DIR}/html"
)
add_custom_target(
  ${PROJECT_NAME}-html ALL
  DEPENDS ${OUT_HTML} ${PROJECT_NAME}-img-html
)
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html"
  DESTINATION ${PROJECT_NAME}
)


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
#  RENAME "ANMS Product Guide v${PROJECT_VERSION}.pdf"
)
