# eol_terms
A very basic repository for terms, their URIs, and their properties that EOL maintains on the site.

## Usage

```
> EolTerms.uris
=> ["http://eol.org/schema/terms/Âµmol_cell-1", "http://eol.org/schema/terms/conePlusHalfSphere-20Percent", etc...]
> EolTerms.validate
Valid.
=> nil
> EolTerms.uri_hash
=> {"http://eol.org/schema/terms/Âµmol_cell-1"=>true, "http://eol.org/schema/terms/conePlusHalfSphere-20Percent"=>true, etc...}
```
