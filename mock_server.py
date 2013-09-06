from itty import get, run_itty, Response
import json

@get('/availableFiles')
def index(request):
    print request.GET['foo']
    files = ["test.txt"]
    return Response(json.dumps({'files': files}), content_type='application/json')

run_itty()