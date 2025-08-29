# Basic Pelican configuration for Docker image build
# Projects will override this with their own pelicanconf.py when mounted

AUTHOR = 'Docker Build'
SITENAME = 'Pelican Docker Build'
SITEURL = 'https://example.com'

PATH = 'content'

TIMEZONE = 'UTC'
DEFAULT_LANG = 'en'

# Feed generation (disabled for development)
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Plugins (projects can override)
PLUGIN_PATHS = []
PLUGINS = [
    'pelican.plugins.series',
    'pelican.plugins.tailwindcss',
#    'pelican.plugins.search'
    ]
TAILWIND = {
    "version": "4.1.12",
    "plugins": [
    
    ],
}

# Theme (projects can override)
# THEME = None

# Static paths (projects can override)
STATIC_PATHS = []

# URL structure (projects can override)
ARTICLE_URL = '{date:%Y}/{date:%m}/{date:%d}/{slug}/'
ARTICLE_SAVE_AS = '{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'
PAGE_URL = '{slug}/'
PAGE_SAVE_AS = '{slug}/index.html'

# Default pagination
DEFAULT_PAGINATION = 10

# Uncomment following line if you want document-relative URLs when developing
# RELATIVE_URLS = True
