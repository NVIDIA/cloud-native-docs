
import sphinx
import os
import logging
import sys
from string import Template

logger = logging.getLogger(__name__)

sys.path += [
    "/work/_repo/deps/repo_docs/omni/repo/docs/include",
]


project = "NVIDIA GPU Operator"

copyright = "2020-2026, NVIDIA Corporation"
author = "NVIDIA Corporation"

release = "25.10"
root_doc = "index"

extensions = [
    "sphinx.ext.autodoc",  # include documentation from docstrings
    "sphinx.ext.ifconfig",  # conditional include of text
    "sphinx.ext.napoleon",  # support for NumPy and Google style docstrings
    "sphinx.ext.intersphinx",  # link to other projects' documentation
    "sphinx.ext.extlinks",  # add roles to shorten external links
    "myst_parser",  # markdown parsing
    "sphinxcontrib.mermaid",  # create diagrams using text and code
    "sphinxcontrib.youtube",  # adds youtube:: directive
    "sphinxemoji.sphinxemoji",  # adds emoji substitutions (e.g. |:fire:|)
    "sphinx_design",
    "repo_docs.ext.inline_only",
    "repo_docs.ext.toctree",
    "repo_docs.ext.mdinclude",
    "repo_docs.ext.include_patch",
    "repo_docs.ext.youtube",
    "repo_docs.ext.ifconfig",
    "repo_docs.ext.source_substitutions",
    "repo_docs.ext.mermaid",
    "repo_docs.ext.exhale_file_fix",
    "repo_docs.ext.output_format_text",
    "repo_docs.ext.output_format_latex",
    "repo_docs.ext.include_licenses",
    "repo_docs.ext.add_templates",
    "repo_docs.ext.breadcrumbs",
    "repo_docs.ext.metadata",
    "repo_docs.ext.confval",
    "repo_docs.ext.customize_layout",
    "repo_docs.ext.cpp_xrefs",
]

# automatically add section level labels, up to level 4
myst_heading_anchors = 4


# configure sphinxcontrib.mermaid as we inject mermaid manually on pages that need it
mermaid_init_js = ""
mermaid_version= ""


intersphinx_mapping = {}
exclude_patterns = [
    ".git",
    "Thumbs.db",
    ".DS_Store",
    ".pytest_cache",
    "_repo",
    "README.md",
    "life-cycle-policy.rst",
    "_build/docs/secure-services-istio-keycloak",
    "_build/docs/openshift",
    "_build/docs/gpu-telemetry",
    "_build/docs/container-toolkit",
    "_build/docs/review",
    "_build/docs/partner-validated",
    "_build/docs/driver-containers",
    "_build/docs/sphinx_warnings.txt",
    "_build/docs/kubernetes",
    "_build/docs/tmp",
    "_build/docs/dra-driver",
    "_build/docs/edge",
    "_build/docs/gpu-operator/24.9.1",
    "_build/docs/gpu-operator/24.12.0",
    "_build/docs/gpu-operator/25.3.4",
    "_build/docs/gpu-operator/25.3.1",
    "_build/docs/gpu-operator/24.9.2",
    "_build/docs/gpu-operator/version1.json",
    "_build/docs/gpu-operator/24.9",
    "_build/docs/gpu-operator/25.3.0",
    "_build/docs/gpu-operator/25.3",
    "_build/docs/gpu-operator/25.10",
]

html_theme = "sphinx_rtd_theme"

html_logo = "/work/assets/nvidia-logo-white.png"
html_favicon = "/work/assets/favicon.ico"

# If true, links to the reST sources are added to the pages.
html_show_sourcelink = False

html_additional_search_indices = []

# If true, the raw source is copied which might be a problem if content is removed with `ifconfig`
html_copy_source = False

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
html_show_sphinx = False

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = [
    "/work/_repo/deps/repo_docs/media",
]

html_last_updated_fmt = ""

# https://sphinx-rtd-theme.readthedocs.io/en/stable/configuring.html
html_theme_options = {
    "logo_only": True,
    "prev_next_buttons_location": None,  # our docs aren't a novel...
    "navigation_depth": 10,
}

html_extra_content_head = ['  <script src="https://assets.adobedtm.com/5d4962a43b79/c1061d2c5e7b/launch-191c2462b890.min.js" ></script>\n  ']
html_extra_content_footer = ['  <script type="text/javascript">if (typeof _satellite !== "undefined") {_satellite.pageBottom();}</script>\n  ']
html_logo_target_url = ""

html_breadcrumbs_home_url = ""
html_extra_breadcrumbs = []

html_css_files = [
    "omni-style.css",
    "api-styles.css",
]

html_js_files = [
    "version.js",
    "social-media.js",
]

# literal blocks default to c++ (useful for Doxygen \code blocks)
highlight_language = 'c++'


# add additional tags



source_substitutions = {'minor_version': '25.10', 'version': 'v25.10.1', 'recommended': '580.105.08', 'dra_version': '25.12.0'}
source_substitutions.update({
    'repo_docs_config': 'debug',
    'repo_docs_platform_target': 'linux-x86_64',
    'repo_docs_platform': 'linux-x86_64',
    'repo_docs_dash_build': '',
    'repo_docs_project': 'gpu-operator',
    'repo_docs_version': '25.10',
    'repo_docs_copyright': '2020-2026, NVIDIA Corporation',
    # note: the leading '/' means this is relative to the docs_root (the source directory)
    'repo_docs_api_path': '/../_build/docs/gpu-operator/latest',
})

# add global metadata for all built pages
metadata_global = {}

sphinx_event_handlers = []
myst_enable_extensions = [
  "colon_fence", "dollarmath",
]
templates_path = ['/work/templates']
extensions.extend([
  "linuxdoc.rstFlatTable",
  "sphinx.ext.autosectionlabel",
  "sphinx_copybutton",
  "sphinx_design",
])
suppress_warnings = [ 'autosectionlabel.*' ]
pygments_style = 'sphinx'
copybutton_exclude = '.linenos, .gp'

html_theme = "nvidia_sphinx_theme"
html_copy_source = False
html_show_sourcelink = False
html_show_sphinx = False

html_domain_indices = False
html_use_index = False
html_extra_path = ["versions1.json"]
html_static_path = ["/work/css"]
html_css_files = ["custom.css"]

html_theme_options = {
  "icon_links": [],
  "switcher": {
    "json_url": "../versions1.json",
    "version_match": release,
  },
}

highlight_language = 'console'

intersphinx_mapping = {
  "dcgm": ("https://docs.nvidia.com/datacenter/dcgm/latest/", "../work/dcgm-offline.inv"),
  "gpuop": ("https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/",
              ("_build/docs/gpu-operator/latest/objects.inv", None)),
  "ctk": ("https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/",
              ("_build/docs/container-toolkit/latest/objects.inv", None)),
  "drv": ("https://docs.nvidia.com/datacenter/cloud-native/driver-containers/latest/",
              ("_build/docs/driver-containers/latest/objects.inv", None)),
  "ocp": ("https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/",
              ("_build/docs/openshift/latest/objects.inv", None)),
  "edge": ("https://docs.nvidia.com/datacenter/cloud-native/edge/latest/",
              ("_build/docs/edge/latest/objects.inv", None)),
}
rst_epilog = ".. |gitlab_mr_url| replace:: Sorry Charlie...not a merge request."
if os.environ.get("CI_MERGE_REQUEST_IID") is not None:
  rst_epilog = ".. |gitlab_mr_url| replace:: {}/-/merge_requests/{}".format(
    os.environ["CI_MERGE_REQUEST_PROJECT_URL"], os.environ["CI_MERGE_REQUEST_IID"])

def setup(app):
    app.add_config_value('build_name', 'public', 'env')
    for (event, handler) in sphinx_event_handlers:
        app.connect(event, handler)
