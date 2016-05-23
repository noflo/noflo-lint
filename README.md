NoFlo Project Linting tool
==========================

noflo-lint can be utilizer for finding and analyzing all dependencies of a NoFlo project. It uses a graph as the entry point and traverses its nodes and sub-graphs to find and check all components used.

## Basic usage

You can run noflo-lint with the command line using the following:

```
$ noflo-lint <baseDir> <graphName>
```

## Configuration

The handling of the various NoFlo linting checks can be configured on three levels: `ignore`, `warn`, and `error`. Failing an error-level check will make the process exit with a non-zero exit code.

Currently the following checks are available:

* `description`: Whether the component has a textual description
* `icon`: Whether the component has an icon set
* `port_descriptions`: Whether all ports have textual descriptions
* `wirepattern`: Whether the component uses the WirePattern helper
* `process_api`: Whether the component uses the Process API
* `asynccomponent`: Whether the component uses the deprecated AsyncComponent API
* `legacy_api`: Whether the component uses legacy NoFlo API (i.e. not WirePattern or Process API)

## Contributing

Additional checks can be added to the `src/check.coffee` file. Each "checker" receives a component instance to inspect.
