+++
authors = ["Mark James Francis"]
title = "Citrix Workspace app fixes for Ubuntu 22.04"
date = "2023-07-16"
+++
fi
I have found my self needing to use the Citrix Workspace App for work. I'm honestly surprised how well it worked on Linux, but I did run into a few issues and wanted to document each fix in one location.

## SSL Error 61: You have not chosen to trust 'Certificate Authority'

I found the [solution](https://support.citrix.com/article/CTX203362/error-ssl-error-61-you-have-not-chosen-to-trust-certificate-authority-on-receiver-for-linux) to be symlinking the Firefox CA certificates.

```bash
 sudo ln -s /usr/share/ca-certificates/mozilla/* /opt/Citrix/ICAClient/keystore/cacerts
```

 ## Unable to resize the client window / No toolbar

 The [solution](https://discussions.citrix.com/topic/412690-citrix-workspace-menue-toolbar-missing/) to this was to add the following config line to `~/.ICAClient/All_Regions.ini`:

 ```bash
 ConnectionBar=1
 ```

 ## Firefox error "Gah. Your tab just crashed." on first restart after installing Citrix Workspace App

 This was an odd issue. I usually sleep my PC between uses so this error turned up several weeks after installing the app. It turns out that the "App Protection" feature of the Citrix app is causing this error. Uninstalling and re-installing without this feature (prompted on install) fixed this issue for me.
