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
* Indexer: ElasticSearch (optional)

These should be running when the engine is started.

The Ruby gem for the database you're using must also be installed (`mysql2`, `freetds` or `sqlite3`).

## Usage

### Engine

To define your engine settings:

```
casa engine setup
```

To start the engine:

```
casa engine start
```

To stp[ the engine:

```
casa engine stop
```

To view options from configuration paths to ports:

```
casa engine help
```

## FAQ

##### Why are the search APIs not working?

The most common reason for this is that the engine was unable to resolve an Elasticsearch database. Please ensure Elasticsearch is running and that the engine settings properly reference it, and then restart the CASA engine.

## License

The CASA Protocol is **open-source** and licensed under the Apache 2 License
license. The full text of the license may be found in the `LICENSE` file.
