<!--
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
-->
# AMMOS Bundle Protocol Security Library (BSL) Documentation

This repository hosts out-of-source documentation related to the AMMOS project to build a Bundle Protocol Security (BPSec) implementation independent of any specific BP Agent implementation.

Out-of-source documentation includes project background, requirements, and design materials.
The in-source documentation includes API documentation, development conventions and scripts, build and runtime needs and procedures, and unit test fixtures.

## Design Documentation

The design of the BSL is based on the overall [BSL Requirements](BSL%20Software%20Requirements%20Document.pdf) for the initial release version.

The initial design overview is presented as [Preliminary Design Review (PDR) slides](BSL%20PDR.pdf) with a more detailed description in the [Critical Design Review (CDR) slides](BSL%20CDR.pdf). All of this earlier design material is superseded by any of the in-source documentation, which represents the actual realized library API and how it may change over time in different versions.

## Manuals

This repository contains User and Product Guides for the BSL.
The User GUide is focused on introducing the API and high-level workflows of the BSL and points to specific parts of the software interface API for lower-level details.
The Product Guide is focused on how to install the runtime and development packages to make use of the BSL and how to maintain and upgrade a deployment of the BSL.

These are written with [AsciiDoc](https://asciidoc.org/) and intended for PDF and HTML publication formats.

Once tools are installed and available, the following commands will build the guide documents.
```
cmake -S . -B build
cmake --build build
cmake --install build
```
