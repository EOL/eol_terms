# eol_terms
A very very basic repository for terms, their URIs, and their properties that EOL maintains on the site.

## Usage

### Getting started

Add the following to your Gemfile:

```
gem 'eol_terms', git: 'git://github.com/EOL/eol_terms.git'
```

### Methods

Get a list of "known" URIs with `#uris`.

```
> EolTerms.uris
=> ["http://eol.org/schema/terms/Âµmol_cell-1", "http://eol.org/schema/terms/conePlusHalfSphere-20Percent", etc...]
> EolTerms.validate
Valid.
=> nil
```

If you prefer to have them as a hash, use `#uri_ids`. The values are EOL's internal IDs, but it might be useful to have
the keys (i.e.: lookup of keys is much faster than with an array).

```
> EolTerms.uri_ids
=> {"http://eol.org/schema/terms/âµmol_cell-1"=>1, "http://eol.org/schema/terms/coneplushalfsphere-20percent"=>2, ...}
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
