# Publish configuration for Docker image build
# Projects will override this with their own publishconf.py when mounted

import os
import sys
sys.path.append(os.curdir)
from pelicanconf import *

# Production settings
SITEURL = 'https://example.com'  # Projects should override this
RELATIVE_URLS = False

# Feed settings for production
FEED_ALL_ATOM = 'feeds/all.atom.xml'
CATEGORY_FEED_ATOM = 'feeds/{slug}.atom.xml'

DELETE_OUTPUT_DIRECTORY = True

# Analytics and other production features (projects can override)
# GOOGLE_ANALYTICS = ""
# DISQUS_SITENAME = ""