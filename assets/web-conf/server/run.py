import tornado.ioloop
import tornado.options
from src import handlers
from tornado.web import Application

'''
The way I generate cookie secret is below:

import base64, datetime, os;
base64.b64encode(
    os.urandom(50) + bytes(str(datetime.datetime.now()), 'utf-8')).decode()
'''


if __name__ == '__main__':
    tornado.options.define(
        "port", default="8080",
        help="run on the given port", type=int)
    tornado.options.parse_command_line()
    app = Application(
        handlers=[
            (r'/', handlers.MainHandler)
        ],
        cookie_secret="TODO: Read above message",
        debug=True,
        xsrf_cookies=True
    )
    app.listen(tornado.options.options.port)
    tornado.ioloop.IOLoop.current().start()
