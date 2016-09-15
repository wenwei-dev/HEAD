import os

DEFAULT_CHARACTER_PATH = os.path.join(
    os.path.dirname(os.path.realpath(__file__)), 'characters')
CHARACTER_PATH = os.environ.get('HR_CHARACTER_PATH', DEFAULT_CHARACTER_PATH)

SESSION_RESET_TIMEOUT = 120  # Timeout seconds for a session to be reset
SESSION_REMOVE_TIMEOUT = 600  # Timeout seconds for a session to be removed

HISTORY_DIR = os.path.expanduser('~/.hr/chatbot/history')
SESSION_DIR = os.path.expanduser('~/.hr/chatbot/session')
TEST_HISTORY_DIR = os.path.expanduser('~/.hr/chatbot/test/history')

SOLR_URL = 'http://localhost:8983'

HR_CHATBOT_AUTHKEY = os.environ.get('HR_CHATBOT_AUTHKEY', 'AAAAB3NzaC')
