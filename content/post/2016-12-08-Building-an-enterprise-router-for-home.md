+++
title = "Building an Enterprise Router for Home"
date = "2016-12-08"
+++

One of my biggest annoyances with home internet connections is bad routers. These cheap, flimsy devices seem to always need rebooting every few weeks. They also come with limited features and tend to be a security [nightmare](http://www.pcworld.com/article/2899732/at-least-700000-routers-given-to-customers-by-isps-are-vulnerable-to-hacking.html). When I moved into my new place, I was provided a [BT Home Hub](http://media.gizmodo.co.uk/wp-content/uploads/2016/03/BT-620x349.jpg), but I think we can do better than this.


# Feature Requirements

I want a device with the following attributes:

1. The ability to run a permanant site to site VPN. This is something I will talk about below, but means the device needs to have a reasonably good CPU.
2. As open source and maintained as possible. This will be on the perimiter of my network, so security is importaint here.
3. Advanced firewall and Traffic Shaping abilities. I'd like to be able to prioritise some traffic over others. This will let me download as fast as possible while also giving a good user expirence to my other devices.
4. To be as silent as possible. This device will live in my living room, behind my sofa.
5. Two ethernet ports are a must. I don't want to be messing around with USB to Ethernet dongles.

# The box

My first thought was to look into an [Intel NUC](http://www.intel.co.uk/content/www/uk/en/nuc/overview.html), the same as I use for a desktop. This would be an expensive and likely overkill for my needs. It also lacks a second ethernet port.

I ended up purchasing a [Jetway JBC311W](http://www.mini-itx.com/store/~JBC311W). This device is still way too much CPU for my needs, but does have the multiple network ports I need. I could likely have saved some money by going with a non-wifi version, but I had hopes to turn this into an access point too. I have not yet attempted this though. I had to buy my own disk and RAM for this device. > 5GB's of storage and > 4GB's of RAM is more than enough for a handful of users. Did I mention that this device is passively cooled, so no moving parts? This should keep it nice and quiet.

I chose [PFSense](https://pfsense.org/) as my OS. I've used this sucsessfully in a previous job, so am furmilier with it's working and benefits.

* This is an actively maintained product, supported by Netgate. This should provide me with all the security updates I'll need.
* It has the option to maintain multiple site to site VPN's and can even [failover](https://doc.pfsense.org/index.php/Multi-WAN) to additional VPN's when a failure condition occures. Very cool.
* It has a very powerful firewall, giving the unlimited control over my inbound and outbound communication.
* Can run basic network services like DHCP, DNS and NAT.
* Has some good additional packages if I wish to run [Squid](https://en.wikipedia.org/wiki/Squid_proxy_server), [Snort](https://en.wikipedia.org/wiki/Snort_(software)) or even an IP block list.


# The Setup

Installing PFSense is simple. Create a [bootable USB](https://doc.pfsense.org/index.php/Installing_pfSense) and follow the on screen instructions.

Once I booted to the device and gave it a static IP (192.168.1.1), I set up some nice [DNS servers](https://dns.watch), away from my ISP.

I then went and configured the DHCP service. I reserved the first 10 IP's in the 192.168.1.0/24 range for networking devices and possible expansion, along with 192.168.1.100-254 as my server range. This left me with 192.168.1.11-99 as my dynamic range. This is more IP's than I will ever need on a home LAN.

##TODO ISP conn

Setting my self up as securly as possible was a key concern for me. I used the following [recomendations](https://www.ivpn.net/setup/router-pfsense.html) on settings, as well as later on to setup my site to site VPN's. I made sure to disable IPv6, as well as setup a block all IPv6 rules on my firewall. This is mainly because I don't yet know the risks involved with IPv6, so I'd rather wait until it's battle tested in the wild a bit longer before I start allowing it.

## Mutli-VPN setup with failover
I wanted to run all my outbound traffic over a VPN. This is a direct response to [The Draft Communications Data Bill](https://en.wikipedia.org/wiki/Draft_Communications_Data_Bill) recently passed in the UK. I should have done this a long time ago, the NSA and GCHQ have been intercepting traffic for years now anyway. It's only a matter of time until these databases are hacked, essentually bringing any data they have on my into the public. We should all be aware that any organiseation is able to be hacked, it's just a matter of time.

The issue with running my internet traffic across a VPN is mainly reliability. I have a few good options to choose from:

1. Use a shared VPN provider, such as [www.ivpn.net](https://www.ivpn.net) for multiple VPN connections, with failover. This is the cheapest option, but relies on the provider not having a network wide outage.
2. Use multiple shared VPN providers, failing over to a compleatly different provider, in a different location when one fails. This will likly give me the best uptime for my connection, but also cost more.
3. Host my own VPN server in the cloud. This will cost more and have bandwidth restrictions. It would also make it easy to target the hosting provider and include my data in a broard compromose.

I decided to go with option 1. and use multiple VPN connections from IVPN. This might change in the future if I run into any issues. Following the guide [here](https://www.ivpn.net/setup/router-pfsense.html) I set up multiple VPN tunnels up. Currently, Iceland and Switzerland are good locations for privacy, but not the best for speed. Using [IVPN's Multi-hop](https://www.ivpn.net/what-is-a-multihop-vpn) with an entry point in the UK seems to improve speeds. This is likely due to some backbone connection agreements between each datacentre they operate from. Running a speed test should give you an idea of the speed, but some providers have been known to inflate these test numbers and give higher bandwidth to these domains.

I then grouped these VPN connections together under a [shared gateway](https://doc.pfsense.org/index.php/Multi-WAN#Summary), using Googles public [anycast](https://en.wikipedia.org/wiki/Anycast) DNS network as an IP to monitor. This is likely the most robust "endpoint" on the internet. If this does not return a response, we can assume the link is down and fail over to the next one.

# Future projects

Now that I have a working router and firewall, with control over passing my traffic via the standard default gateway and out to my ISP, or over my VPN, it's time to look at future improvements and projects.

Something I want to do but have not yet had time too is enable this device as a VPN server. This will allow me to connect in via my phone or remote and either use my normal internet connection or my tunnel. For security, I might setup a dedicated tunnel. Having a self hosted VPN server in my home removes the possible attack vector comming from my hosting provider.

Setting up some alerting would also be nice. Some general graphs showing outbound traffic, along with some summary of inbound traffic would be interesting. I don't expect to get hit with much inbound, but it would be good to visualise this. It would also be a good idea to get email alerts for anything critical. I could use my gmail account, or possibly something like [Mailgun](https://documentation.mailgun.com/quickstart-sending.html#send-via-api). They have a free tier that will more than cover my usage.

Adding encryption to my backups should really also be done before being uploaded to S3. I should also verify no passwords, or sensitive information is contained within these backups, and change them if found.

Adding some QoS to give my desktop a [higher priority](https://doc.pfsense.org/index.php/Traffic_Shaping_Guide) to network resources would also be nice. I've had a few instances of slow desktop performance when other devices are running at full speed. Unfortunatly I can't extend this to my LAN, so heavy transfer to and from my NAS box can still degrade performance.
