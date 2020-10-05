+++
title = "Hosting a static blog on S3 using Jekyll"
date = "2016-03-08"
+++

This is a simple overview of the decisions and steps I took to implement this basic blog. As of the writing of this post I'm serving it through [AWS CloudFront](https://aws.amazon.com/cloudfront/) from [AWS S3](https://aws.amazon.com/s3/), with DNS via [AWS Route 53](https://aws.amazon.com/route53/). It's not using any conventional server infrastructure and cost pennies to run each month.

When researching a candidate framework for a simple blog, my first port of call was [Wordpress](https://wordpress.com/), the long-standing king of blogs. Unfortunately Wordpress is overkill for my needs, with extensive functionality I will never use. It also requires conventional server infrastructure, including a database, which will cost good money to implement correctly. My professional experience with Wordpress is also reasonable negative, often revolving around unpatched plugins and security exploits. If I can avoid most of these issues all together, that will be less effort to maintain on my end.

<amp-img width="600" layout="responsive" src="/assets/images/jekyll.png"></amp-img>

After eliminating Wordpress, I started looking at static blogs. I really liked the idea of not having to run infrastructure, even being able to host on Github via [Github Pages](https://pages.github.com/). I decided I wanting more control over my hosting than Github Pages provided, so started to look around for alternatives with good integration with AWS S3 and CloudFront (The tech stack I'm used professionally). After a brief attempt at using [Pelican](http://blog.getpelican.com/) I ended up taking a look at the popular [Jekyll](https://jekyllrb.com/) Framework. Ruby is a whole new area for me so I was excited to get to grips with some of the basic and maybe learn something new.

A key factor for me in this choice was speed. I really wanted a super fast blog with a modern look and feel. I came across [Google's AMP Project](https://www.ampproject.org/) which aims at giving you the libraries and design frameworks to make a fast, content first website or blog. Luckily for me some one had already created a nice [Jekyll theme using [AMP](https://github.com/ageitgey/amplify) which I really liked.

The final component I needed was a nice, automated way of uploading new content to S3. After mere seconds of searching online, I came across [s3_website](https://github.com/laurilehmijoki/s3_website) which has already done all the hard work for me. All I needed to do was add IAM keys with access to S3 and CloudFront and it setup the S3 bucket and CloudFront endpoint for me. In the future I might make a handy script to create these resources if they don't already exist. Unfortunately that would likely mean hard-coding them in version control.


# The implementation

I pulled the [Amplify](https://github.com/ageitgey/amplify) theme and started to modify the _config.yml file with my own details. I was shocked how easy it was to get a basic framework to the point where I could start adding content.

I then added the [S3_website](https://github.com/laurilehmijoki/s3_website) scripts and updated the s3_website.yml file to point to some local environmental variables. This allows me to commit the upload config file without committing any passwords or keys.

I then wrote some test posts using the example post included with my chosen template and added it to the _posts directory. When complete, I ran the command "s3_website push" to generate my HTML files and upload them to S3. The script will create any needed infrastructure if needed and the site should then be viewable as soon as the CloudFront cache refreshes.

# ... fixing my bad spelling

After writing blog posts, I needed a nice way to correct my mispelt words. I had a look around on Google and found a command line utility for Linux that I'd never heard of before, [aspell](http://rajaseelan.com/2009/07/15/check-your-spelling-in-linux-using-the-command-line/). It looks like I can specify a file of allowed words in the same directory, which lends it's self very well to version controlling the whole site. It also allows me to whitelist the many, many acronyms that us computer folks seem to enjoy so much.

# Security

It seems as though AWS is giving me gift after gift. With the release of [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/), I can now register free SSL certificates, to be served straight from AWS CloudFront. All I need to do is have an inbox to receive the verification email. It look all of 10 minutes from start to finish to get this served from CloudFront.

# Monitoring

I will need something to monitor that the page is always up. Since Pingdom has removed it's free tier, I will need to look for something else. [Uptime Robot](https://uptimerobot.com/) is used by some big names, but [StatusCake](https://www.statuscake.com/) seems to be based in my home country (the UK) so I might end up going with them.

# Speed Tests

I wanted to see how fast this site actually was after being propagated to a requested CloudFront region. I can see this page loading in Europe at about 300ms, which Pingdom rates at 80/100. This is more than fast enough to seem almost instant to an end user, even not taking into account the AMP improvements at increasing the load speed of the actual content.

# Outstanding Issues

* Currently I'm debating the value of a comments section, which I currently lack. The purpose of this blog was to share any useful bits of information I come across that have caused my pain in the past, in the hopes of letting other people avoid them. With a comments section, this would involve me having an active presence which I don't currently have time for. This might change in the future, but in the mean time, people can reach me via the email address posted below.

* Adding a script to automate the creation of an IAM user and any resources needed that's not covered by s3_website.

* Write a better README file. I will likely forget how to edit this blog in 6 months, so writing instructions for my future self now sounds like a good idea.
