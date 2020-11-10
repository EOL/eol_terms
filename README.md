# eol_terms
A very very basic repository for terms, their URIs, and their properties that EOL maintains on the site.

## Usage

### Getting started

Add the following to your Gemfile:

```
gem 'eol_terms', git: 'https://github.com/EOL/eol_terms.git'
```

### Workflow

1. Someone edits the terms.yml file.
2. Someone bumps the version, then
3. builds and installs the gem locally

```
rake build ; rake install ; irb -r eol_terms
```

...then runs `EolTerms.validate` to ensure it's valid. If not, return to step 1.

4. That same person figures out the path of their repo (e.g.: `path = '/Users/jrice/git/eol_terms'`), runs `EolTerms.rebuild_ids("#{path}/resources/uri_ids.yml")`, then
5. commits/pushes the changes to the repository, then
6. goes to beta and runs `bundle update eol_terms` (and checks the log for the line confirming the version changed), and
7. runs `TermBootstrapper.new.load` from a console or with `rails runner`, making note of any errors or exceptions.
8. Someone should check that everything looks acceptable... and, if so,
9. run the `bundle update eol_terms` and `TermBootstrapper.new.load` on production, and finally,
10. restart the workers (`bin/stop_work` usually does the trick).

### Methods

Get a list of "known" URIs with `#uris`.

```
> EolTerms.uris
=> ["http://eol.org/schema/terms/Âµmol_cell-1", "http://eol.org/schema/terms/conePlusHalfSphere-20Percent", etc...]
> EolTerms.validate
Valid.
=> nil
```

EolTerms also stores an internal hash of Terms. You can get them with `.by_uri`:

```
> EolTerms.by_uri('http://eol.org/schema/terms/percentPerMonth')
=> {"attribution"=>"", "definition"=>"a measure of specific growth rate", etc...}
```

If you add a URI to the `eol_terms.yml` file, you will need to give IDs to the new terms. This is accomplished with the
`rebuild_ids` method (note that the URIs will necessarily be lowercase when added to the file; URIs are
case-insensitive, so this is just for simplicity):

```
> EolTerms.rebuild_ids
Adding missing key: http://eol.org/schema/terms/coneplushalfsphere-20percent (#1)
Done.
=> nil
```
