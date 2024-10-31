# Plugin Settings

This page describes all of the plugin's settings.

## Console

### Console Key Shortcut

This setting defines the key that the addon will listen for at runtime to grab focus into the terminal.
The default is backtick/backquote/tilde.

## Logging

### Logging Quantity

Also referred to as the Logging Level, this setting controls how much information is logged into the console by the addon.

The `Verbose` and `All` options are pretty much only intended for development of the addon itself. Most logs are from internal systems of the addon, and is not information that is useful to the user.

`Minimal`, however, is a great option if you are getting started with the addon or experiencing an involved issue and would like to see what the addon is doing.

### Logging Types

Controls what types of information is logged in to the console by the addon via whitelist. 

Once again, this is pretty much only intended for development of the addon itself. This setting only becomes useful when there is a large amount of logs occurring, something that the user should not have happening.