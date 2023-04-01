TODO
====

* [ ] Premier boot :
    * [ ] Configurer octoprint :
        * [ ] (TODO à rédiger)
    * [ ] Splashscreen :
        * [ ] Installation du splashscreen
        * [ ] Configuration systemd
        * [ ] L'image du splashscreen
    * [ ] OctoDash :
        * [X] Installation
        * [ ] Configuration du module
        * [ ] Lancement auto au démarrage
        * [ ] Configuration du screen :
            * [ ] Voron 1
            * [ ] Voron 2
        * [ ] Script de mise à jour auto
    * [ ] Rajouter le script https://github.com/KiloQubit/probe_accuracy
* [ ] Scripts :
* [ ] Màj :
    * [ ] Script pour octodash
    * [ ] Script pour octoprint :
        * [ ] A refaire en python pour vérifier l'état d'octoprint (ready) avant
    * [ ] Script pour mettre à jour les scripts git custom :
        * [ ] En utilisateur "pi"
        * [ ] En root lors du boot
        * [ ] Fichier dans le partage pour savoir la version actuelle
* [ ] Divers :
    * [ ] Compiler image pour réinstallation direct :
        * [ ] Redimenssionner les partitions
    * [ ] Serveur nodejs GPIO :
        * [ ] Configuration des sources
        * [ ] Installation
        * [ ] Bouton/script pour activer/désactiver le serveur
    * [ ] Compléter la doc



Bug first boot
==============

ADXL :
```
E: Package 'python-numpy' has no installation candidate
E: Package 'python-matplotlib' has no installation candidate
```

Update octoprint :  
octo pas prêt donc :
```
> Vérification des mises à jour
  => Octoprint
Traceback (most recent call last):
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/connectionpool.py", line 703, in urlopen
    httplib_response = self._make_request(
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/connectionpool.py", line 449, in _make_request
    six.raise_from(e, None)
  File "<string>", line 3, in raise_from
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/connectionpool.py", line 444, in _make_request
    httplib_response = conn.getresponse()
  File "/usr/lib/python3.9/http/client.py", line 1347, in getresponse
    response.begin()
  File "/usr/lib/python3.9/http/client.py", line 307, in begin
    version, status, reason = self._read_status()
  File "/usr/lib/python3.9/http/client.py", line 289, in _read_status
    raise BadStatusLine(line)
http.client.BadStatusLine: Not found

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/home/pi/oprint/lib/python3.9/site-packages/requests/adapters.py", line 489, in send
    resp = conn.urlopen(
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/connectionpool.py", line 787, in urlopen
    retries = retries.increment(
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/util/retry.py", line 550, in increment
    raise six.reraise(type(error), error, _stacktrace)
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/packages/six.py", line 769, in reraise
    raise value.with_traceback(tb)
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/connectionpool.py", line 703, in urlopen
    httplib_response = self._make_request(
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/connectionpool.py", line 449, in _make_request
    six.raise_from(e, None)
  File "<string>", line 3, in raise_from
  File "/home/pi/oprint/lib/python3.9/site-packages/urllib3/connectionpool.py", line 444, in _make_request
    httplib_response = conn.getresponse()
  File "/usr/lib/python3.9/http/client.py", line 1347, in getresponse
    response.begin()
  File "/usr/lib/python3.9/http/client.py", line 307, in begin
    version, status, reason = self._read_status()
  File "/usr/lib/python3.9/http/client.py", line 289, in _read_status
    raise BadStatusLine(line)
urllib3.exceptions.ProtocolError: ('Connection aborted.', BadStatusLine('Not found'))

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/home/pi/oprint/bin/octoprint", line 8, in <module>
    sys.exit(main())
  File "/home/pi/oprint/lib/python3.9/site-packages/octoprint/__init__.py", line 936, in main
    octo(args=args, prog_name="octoprint", auto_envvar_prefix="OCTOPRINT")
  File "/home/pi/oprint/lib/python3.9/site-packages/click/core.py", line 1130, in __call__
    return self.main(*args, **kwargs)
  File "/home/pi/oprint/lib/python3.9/site-packages/click/core.py", line 1055, in main
    rv = self.invoke(ctx)
  File "/home/pi/oprint/lib/python3.9/site-packages/click/core.py", line 1657, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/home/pi/oprint/lib/python3.9/site-packages/octoprint/cli/common.py", line 37, in invoke
    return self._impl.invoke(ctx)
  File "/home/pi/oprint/lib/python3.9/site-packages/click/core.py", line 1657, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/home/pi/oprint/lib/python3.9/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/home/pi/oprint/lib/python3.9/site-packages/click/core.py", line 760, in invoke
    return __callback(*args, **kwargs)
  File "/home/pi/oprint/lib/python3.9/site-packages/octoprint/plugins/softwareupdate/cli.py", line 61, in check_command
    r = client.get("plugin/softwareupdate/check", params=params)
  File "/home/pi/oprint/lib/python3.9/site-packages/octoprint_client/__init__.py", line 260, in get
    return self.request("GET", path, params=params, timeout=timeout)
  File "/home/pi/oprint/lib/python3.9/site-packages/octoprint_client/__init__.py", line 256, in request
    response = s.send(request, timeout=timeout)
  File "/home/pi/oprint/lib/python3.9/site-packages/requests/sessions.py", line 701, in send
    r = adapter.send(request, **kwargs)
  File "/home/pi/oprint/lib/python3.9/site-packages/requests/adapters.py", line 547, in send
    raise ConnectionError(err, request=request)
requests.exceptions.ConnectionError: ('Connection aborted.', BadStatusLine('Not found'))
Initializing settings & plugin subsystem...
  => Plugins
```