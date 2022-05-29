{
	"config": {
		"octoprint": {
			"url": "http://localhost:5000/",
			"accessToken": "API_KEY"
		},
		"printer": {
			"name": "Voron",
			"xySpeed": 150,
			"zSpeed": 5,
			"disableExtruderGCode": "M18 E",
			"zBabystepGCode": "M290 Z",
			"defaultTemperatureFanSpeed": {
				"hotend": 200,
				"heatbed": 60,
				"fan": 100
			}
		},
		"filament": {
			"thickness": 1.75,
			"density": 1.25,
			"feedLength": 0,
			"feedSpeed": 20,
			"feedSpeedSlow": 3,
			"purgeDistance": 30,
			"useM600": false
		},
		"plugins": {
			"displayLayerProgress": {
				"enabled": true
			},
			"enclosure": {
				"enabled": true,
				"ambientSensorID": 1,
				"filament1SensorID": null,
				"filament2SensorID": null
			},
			"filamentManager": {
				"enabled": false
			},
			"preheatButton": {
				"enabled": true
			},
			"printTimeGenius": {
				"enabled": true
			},
			"psuControl": {
				"enabled": false,
				"turnOnPSUWhenExitingSleep": false
			},
			"tpLinkSmartPlug": {
				"enabled": false,
				"smartPlugIP": "127.0.0.1"
			},
			"tasmota": {
				"enabled": false,
				"ip": "127.0.0.1",
				"index": null
			},
			"tasmotaMqtt": {
				"enabled": false,
				"topic": "topic",
				"relayNumber": null
			}
		},
		"octodash": {
			"customActions": [
				{
					"color": "#dcdde1",
					"command": "G28",
					"confirm": false,
					"exit": false,
					"icon": "home"
				},
				{
					"color": "#c0c1c4",
					"command": "G29",
					"confirm": false,
					"exit": false,
					"icon": "parking"
				},
				{
					"color": "#e1b12c",
					"command": "M140 S60; M104 S200",
					"confirm": false,
					"exit": true,
					"icon": "fire-alt"
				},
				{
					"color": "#0097e6",
					"command": "M140 S0; M104 S0",
					"confirm": false,
					"exit": true,
					"icon": "snowflake"
				},
				{
					"color": "#7f8fa6",
					"command": "[!RELOAD]",
					"confirm": true,
					"exit": false,
					"icon": "redo-alt"
				},
				{
					"color": "#e84118",
					"command": "[!SHUTDOWN]",
					"confirm": true,
					"exit": false,
					"icon": "power-off"
				},
				{
					"color": "#ffc01f",
					"command": "M118 //action:light_on",
					"confirm": false,
					"exit": false,
					"icon": "lightbulb"
				},
				{
					"color": "#5e5e5e",
					"command": "M118 //action:light_off",
					"confirm": false,
					"exit": false,
					"icon": "lightbulb"
				},
				{
					"color": "#53b02b",
					"command": "M118 //action:extract_on",
					"confirm": false,
					"exit": false,
					"icon": "fan"
				},
				{
					"color": "#a84931",
					"command": "M118 //action:extract_off",
					"confirm": false,
					"exit": false,
					"icon": "fan"
				},
				{
					"color": "#9c59db",
					"command": "[!WEB]http://localhost/plugin/octodashcompanion/webcam",
					"confirm": false,
					"exit": false,
					"icon": "video"
				},
				{
					"color": "#667cd6",
					"command": "G32",
					"confirm": false,
					"exit": false,
					"icon": "layer-group"
				}
			],
			"fileSorting": {
				"attribute": "name",
				"order": "asc"
			},
			"invertAxisControl": {
				"x": false,
				"y": false,
				"z": false
			},
			"pollingInterval": 2000,
			"touchscreen": true,
			"turnScreenOffWhileSleeping": false,
			"turnOnPrinterWhenExitingSleep": false,
			"preferPreviewWhilePrinting": true,
			"previewProgressCircle": true,
			"screenSleepCommand": "xset dpms force standby",
			"screenWakeupCommand": "xset s off && xset -dpms && xset s noblank"
		}
	}
}