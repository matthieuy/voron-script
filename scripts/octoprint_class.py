#!/usr/bin/python3

import requests
from json import JSONDecodeError
from environ import Env

# Chargement du fichier .env
env = Env()
env.read_env()



class Octoprint:
    DEBUG = False
    STATUS_CLOSED = 'Closed'
    STATUS_OFFLINE = 'Offline'
    STATUS_OPERATIONAL = 'Operational'
    STATUS_SERIAL = 'Opening serial connection'


    def __init__(self, debug = False) -> None:
        '''
        Init the class
        :param bool debug: Active debug mode
        '''
        self.DEBUG = debug
        self.API_KEY = env('OCTOPRINT_API_KEY')
        self.API_BASE = 'http://%s/api' % env('OCTOPRINT_IP')
        self.HEADER_API = {
            'X-Api-Key': self.API_KEY,
            'Content-Type': 'application/json',
        }


    def get_status(self) -> str:
        '''
        Get the status of the print
        :return str: Status
        '''
        # Do request
        try:
            response = self.__do_get_request('/connection')
        except:
            return self.STATUS_OFFLINE

        # Check HTTP code
        if response.status_code != 200:
            if self.DEBUG:
                print("[DEBUG] Return code : %d" % response.status_code)
            return self.STATUS_OFFLINE
        
        # Check JSON
        try:
            result = response.json()
        except JSONDecodeError as e:
            if self.DEBUG:
                print("[DEBUG] Bad json content : %s" % e)
            return self.STATUS_OFFLINE
        if self.DEBUG:
            print("Content of request : %s" % result)

        # Check status
        if 'current' not in result or 'state' not in result['current']:
            return self.STATUS_OFFLINE
        if self.DEBUG:
            print("[DEBUG] State of print : %s" % result['current']['state'])
        return result['current']['state']
    

    def connect_print(self, disconnect = False) -> bool:
        '''
        Connect or disconnect printer
        :param bool disconnect: Disconnect instead of connect
        :return bool: Success or not
        '''
        try:
            if disconnect:
                data = {'command': 'disconnect'}
            else:
                data = {'command': 'connect'}
            response = self.__do_post_request('/connection', data)
            return response.status_code == 204
        except:
            return False


    def send_gcode(self, gcode: str) -> bool:
        '''
        Send a GCODE command
        :param str gcode: The GCODE to send
        :return bool: Succes or not
        '''
        try:
            data = {'command': gcode}
            response = self.__do_post_request('/printer/command', data)
            return response.status_code == 204
        except Exception as e:
            if self.DEBUG:
                print("Error API : %s" % e)
            return False
       

    def __do_get_request(self, path: str) -> requests:
        '''
        Do a GET request
        :param str path: The path of API
        :return requests: The request
        '''
        try:
            url = self.API_BASE + path
            if self.DEBUG:
                print("[DEBUG] Do GET request %s" % url)
            return requests.get(url, headers=self.HEADER_API)
        except Exception as e:
            raise requests.ConnectionError("Erreur API : %s" % e)


    def __do_post_request(self, path: str, data) -> requests:
        '''
        Do a POST request
        :param str path: The path of API
        :param data: The data to send
        :return requests: The request
        '''
        try:
            url = self.API_BASE + path
            if self.DEBUG:
                print("[DEBUG] Do POST request %s : %s" % (url, data))
            return requests.post(url, headers=self.HEADER_API, json=data)
        except Exception as e:
            raise requests.ConnectionError("Erreur API : %s" % e)
    