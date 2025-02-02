# Collectd Plugins

This is a repository of scripts that can be run with [collectd's](https://www.collectd.org/) `exec` plugin.

## Installation

1. Make sure you have the prerequisites installed on your system. See each plugin for details.
2. Enable the `exec` plugin:
	```
	LoadPlugin exec
	```
4. Copy the plugin to a location on your system. Make sure it is executable.
5. Add the following configuration to your collectd configuration file:
	```
	<Plugin exec>
		Exec "nobody:nogroup" "/path/to/plugin"
	</Plugin>
	```
	where `/path/to/plugin` is the path to the plugin, and `nobody:nogroup` is the user and group that collectd should run the plugin as.
6. Restart collectd.

### Example

The plugins echo `PUTVAL` ([plain-text protocol](https://github.com/collectd/collectd/wiki/Plain-text-protocol)) lines to stdout.

## Support/Contact

For enterprise licensing, support, and consulting, please visit [our website](https://pextra.cloud/services/support). Alternatively, you can contact us at [support@pextra.cloud](mailto:support@pextra.cloud).

If you have any questions, please feel free open an issue or a discussion.

## License

This repository is licensed under the [Apache 2.0 License](./LICENSE).
