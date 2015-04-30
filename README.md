# sep

Basic module for managing Symantec Endpoint Protection.

----

## How to use

```puppet
class { 'sep':
  source        => '\\UNCPATH',
  deploy_sylink => true,
  sepm_ip       => 'ip_address_of_sepm_server',
} 
```
>Note:
>
>1. The installer packages of SEP for both 64bit and 32bit Windows need to be copied to `\\UNCPATH`.
>
>2. If `deploy_sylink` is true, `sylink.xml`(the communication file exported from SEPM Server) is required and should be placed under `./files` folder. `sepm_ip` parameter is also required.

## Custom Facts

The client status is collected as `sep` fact. For example:

```javascript
sep => {"managed"=>true, "service"=>"enabled", "definition"=>"2015-04-28", "sepm "=>"127.16.1.111", "version"=>"12.1.4112.4156", "path"=>"C:\\Program Files\\Symantec\\Symantec Endpoint Protection\\12.1.4112.4156.105\\Bin\\", "online"=>true}
```

I wrote it for fitting the environment of my company, so it's not flexible at all.

Will figure out a general module for managing SEP client without SEPM.
