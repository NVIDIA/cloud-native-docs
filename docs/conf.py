#
# Copyright (c) 2024, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

from datetime import date

project = "Securing NVIDIA Services with Istio and Keycloak"
this_year = date.today().year
copyright = f"2023-{this_year}, NVIDIA Corporation"
author = "NVIDIA Corporation"

extensions = [
    "sphinx_rtd_theme",
    "myst_nb",
    "sphinx.ext.intersphinx",
    "sphinx_copybutton",
]

copybutton_exclude = '.linenos, .gp, .go'

myst_linkify_fuzzy_links = False
myst_heading_anchors = 3
myst_enable_extensions = [
    "deflist",
    "dollarmath",
    "fieldlist",
    "substitution",
]

exclude_patterns = [
    "_build/**",
]

intersphinx_mapping = {
    'gpu-op': ('https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest', None),
    'ocp': ('https://docs.nvidia.com/datacenter/cloud-native/openshift/latest', None),
    'ngc-cli': ('https://docs.ngc.nvidia.com/cli/', None)
}

# suppress_warnings = ["etoc.toctree", "myst.header", "misc.highlighting_failure"]

html_theme = "sphinx_rtd_theme"
html_copy_source = False
html_show_sourcelink = False
html_show_sphinx = False

html_theme_options = {
    "logo_only": True,
    "titles_only": True,
}

html_domain_indices = False
html_use_index = False
html_extra_path = ["versions.json", "project.json"]
highlight_language = 'console'

html_static_path = ["media"]
html_css_files = [
    "omni-style.css",
    "custom.css"
]

html_js_files = [
    "version.js"
]

html_logo = "media/nvidia-logo-white.png"
html_favicon = "media/favicon.ico"
html_baseurl = "https://docs.nvidia.com/nim-operator/latest/"

templates_path = ["templates"]

