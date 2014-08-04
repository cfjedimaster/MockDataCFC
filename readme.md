MockData CFC
===

This is a ColdFusion version of the [MockData](https://github.com/cfjedimaster/mockdata) Node.js service
I built sometime ago. Unlike the Node version this isn't obviously a service on its own. Rather, you simply
copy the CFC to your web server (with ColdFusion installed) and then call it from your client-side code or
other scripts. The full docs for how this works may be found on the Node.js version, but as an example, this
call will return 10 random names:

http://localhost:8501/mock/mockdata.cfc?person=name

Notice that you do not need to pass either the method or return type. The CFC automatically selects
the mock method and automatically returns JSON. 