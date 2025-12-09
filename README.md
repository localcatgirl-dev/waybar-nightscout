# waybar-nightscout
Just a simple waybar module with a script
The script is not completed but it is good for the basic functionality.

Add your nightscout url in nightscout.sh in
`NS_URL="______________"`

## Module template
### config.json
``` JSON
{
  "modules-right": [ "custom/nightscout" ],

  "custom/nightscout": {
    "exec": "~/.config/waybar/scripts/nightscout.sh",
    "interval": 60,
    "return-type": "json",
    "format": "{text}"
  }
}
```
### style.sss
```CSS
#custom-nightscout {
    border-radius: 0px;
    padding: 4px 12px;
}

/* Nightscout low */
#custom-nightscout.range-low {
    background-color: purple;
    color: white;
}

/* Nightscout high */
#custom-nightscout.range-10_12 {
    background-color: yellow;
    color: white;
}

/* Nightscout very high */
#custom-nightscout.range-13_159 {
    background-color: orange;
    color: white;
}

/* Nightscout critical high */
#custom-nightscout.range-16plus,
#power-profiles-daemon.performance {
    background-color: red;
    color: black;
}
```
