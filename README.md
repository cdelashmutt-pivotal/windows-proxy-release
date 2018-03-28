# Windows Set Proxy Release
The set-proxy BOSH release provides a job that can be used to set proxies for WinInet (Machine-wide) and WinHTTP.  The jobs in this release can be used as an [addon](http://bosh.io/docs/runtime-config.html#addons), to configure a Windows stemcell based deployment.

## Installing

### Installing a Pre-built Release
Download the latest release tarball from github, and then upload it to your BOSH director with the following command as an example:
```
bosh -e vbox upload-release windows-proxy-0.1.0.tgz
```

### Installing from source
Clone this repo to your machine, cd into the cloned repository, and issue the following commands to upload a dev release to your director:
```
bosh create-release --force
bosh -e vbox upload-release
```
Note the release version number created in the output of the `create-release` command, as you will use that release version in your runtime config below.

## Apply the release via a runtime-config
Include the release in your runtime-config.yml, replacing `<some-version>` with the version for the release you uploaded:
```yaml
---
releases:
...
- name: windows-proxy
  version: <some-version>
```

### Setting the proxy settings
Also in your runtime-config.yml, specify the following in your `addons` section to apply the job to your `windows2012R2` based VMs (replacing the `proxy-url` and `bypass-list` with your settings for proxy):
```yaml
addons:
...
- name: set-proxy-addon
  jobs:
  - name: set-proxy
    release: windows-proxy
    properties:
      set-proxy:
        enabled: true
        proxy-url: http://192.168.1.1:8080
        bypass-list: "*.local;<local>"
  include:
    stemcell:
    - os: windows2012R2
```
**Note:** The `bypass-list` setting is a semi-colon separated list following the format specified at https://technet.microsoft.com/en-us/library/cc939852.aspx#EBAA
