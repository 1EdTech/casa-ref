# CASA Reference Implementation

The [Community App Sharing Architecture (CASA)](http://imsglobal.github.io/casa) provides a mechanism for
discovering and sharing metadata about web resources such as websites, mobile
apps and LTI tools. It models real-world decision-making through extensible
attributes, filter and transform operations, flexible peering relationships,
etc.

## Setup

Requires:

* Ruby 1.9 or above
* RubyGems
* Bundler

Install from RubyGems:

```
gem install casa --dev
```

The CASA engine additionally includes persistence layers:

* Database: MySQL, MsSQL or SQLite (required)
* Indexer: Elasticsearch (optional)

These should be running when the engine is started.

The Ruby gem for the database you're using must also be installed (`mysql2`, `freetds` or `sqlite3`).

Finally, you should also make sure to install any gems needed for the attributes you'll be using. The default attribute set, which is configured into `~/.casa/attributes` by default after you run `casa engine setup`, requires:

```
gem install casa-attributes-common
```

## Usage

### Engine

To define the engine settings:

```
casa engine setup
```

To start the engine:

```
casa engine start
```

To get the status of the engine:

```
casa engine status
```

To stop the engine:

```
casa engine stop
```

To view options from configuration paths to pid files:

```
casa engine help
```

### Admin Outlet

To define the admin outlet configuration:

```
casa admin_outlet setup
```

To start the admin outlet:

```
casa admin_outlet start
```

To get the status of the admin outlet:

```
casa admin_outlet status
```

To stop the admin outlet:

```
casa admin_outlet stop
```

To view options from configuration paths to pid files:

```
casa admin_outlet help
```

## Configuration

By default, the base directory containing all CASA configuration files and sub-directories is `~/.casa`. Alternatively, a different path may be specified with the `--settings-dir` argument.

### Engine

#### Engine Configuration

By default, the engine configuration should be defined in `engine.json` within the settings directory. If all defaults are used, attributes will be located under `~/.casa/engine.json`. Alternatively, a path relative to the base configuration directory may be specified with the `--engine-settings-file` argument.

The `casa engine setup` command walks the user through the process of creating this file.

The following are descriptions of each configuration setting during `casa engine setup`:

* `UUID` - A 128-bit unique identifier in the format defined by [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt) that will be used as the `originator_id` when the engine publishes apps (example: `c3ae347f-f12d-4815-a6f7-c1befa07048f`).
* `Port` - The port over which the engine will expose its web service interface (default: `9600`).
* `Database Adapter` - May be `mysql`, `mssql` or `sqlite` (default: `sqlite`).
* `Database Host` - For `mysql` and `mssql`, specifies the host where the database resides (default: `localhost`).
* `Database Username` - For `mysql` and `mssql`, specifies the username to access the database (default: `root`).
* `Database Password` - For `mysql` and `mssql`, specifies the password to access the database (default: none).
* `Database Name` - For `mysql` and `mssql`, specifies a name (default: `casa`), and for `sqlite`, specifies a file (default: `db.sqlite3`).
* `Elasticsearch` - Whether or not to use the Elasticsearch indexer, which makes it possible to issue requests to `/local/payloads` with the `query` parameter for a text search and to issue requests to `/local/payloads/_Elasticsearch` with an Elasticsearch query string (default: `yes`).
* `Elasticsearch Host` - An array of host URIs where Elasticsearch nodes are running (default: `http://localhost:9200`).
* `Refresh Interval for ReceiveIn` - Specifies how often the engine should query its peers, using a format that accepts values such as `15m`, `2h` or `1d` (default: `1h`).
* `Refresh Interval for LocalToAdjOut` - Specifies how often the engine should refresh the payloads it will share with its peers in the event that they fall out of sync, using a format that accepts values such as `15m`, `2h` or `1d` (default: `1d`).
* `Refresh Interval for AdjInToAdjOut` - Specifies how often the engine should refresh the payloads it received from peers that it will propagate to its peers in the event that they fall out of sync, using a format that accepts values such as `15m`, `2h` or `1d` (default: `1d`).
* `Refresh Interval for AdjInToLocal` - Specifies how often the engine should refresh the payloads it received from peers that it will share locally in the event that they fall out of sync, using a format that accepts values such as `15m`, `2h` or `1d` (default: `1d`).
* `Refresh Interval for RebuildLocalIndex` - Specifies how often the engine should rebuild its local index in the event that it falls out of sync, using a format that accepts values such as `15m`, `2h` or `1d` (default: `3d`).
* `Admin Outlet Username` - The username that a user must provide to the admin outlet in order to edit payloads contained within the engine.
* `Admin Outlet Password` - The password that a user must provide to the admin outlet in order to edit payloads contained within the engine.
* `Admin Outlet Origin` - The path to the admin outlet that will edit payloads, required because of CORS restrictions (default: `http://localhost:9601`).

#### Attribute Configuration

By default, the attribute configuration files should be defined under the `attributes/` directory within the CASA base directory. If all defaults are used, attributes will be located under `~/.casa/attributes/`.

The `casa engine setup` command creates empty attribute settings file for each attribute in [casa-attributes-common](https://github.com/imsglobal/casa-attributes-common). Any additional attributes added to CASA should have an attribute file added here.

### Admin Outlet

#### Admin Outlet Configuration

By default, the admin outlet configuration should be defined in `admin_outlet-engine_config.js` within the settings directory. If all defaults are used, this file will be located at `~/.casa/admin_outlet-engine_config.js`. Alterantively, a path relative to the base configuration directory may be specified with the `--outlet-settings-file` argument.

The `casa admin_outlet setup` command walks the user through the process of creating this file.

The following are descriptions of each configuration setting during `casa engine setup`:

* `Engine URL` - The location of the engine to be administered by this outlet (example: `http://localhost:9600`).
* `Engine UUID` - The 128-bit unique identifier for the engine that the outlet will administer (example: `c3ae347f-f12d-4815-a6f7-c1befa07048f`).

## FAQ

##### Why are the search APIs not working?

The most common reason for this is that the engine was unable to resolve an Elasticsearch database. Please ensure Elasticsearch is running and that the engine settings properly reference it, and then restart the CASA engine.

## License

The CASA Protocol is **open-source** and licensed under the Apache 2 License. The full text of the license may be found in the `LICENSE` file.
