+++
title = "My experience taking the AWS Solutions Architect exam"
date = "2016-08-12"
+++

On the 8th of August I passed my [AWS solutions architect exam - Associate](my-experience-taking-the-aws-solutions-architect-exam). I'm hoping that my experience of this can help out anyone else attempting to take the same exam. I'm limited by the [confidentiality](https://aws.amazon.com/certification/certification-agreement/) rules put in place by AWS, but I'm sure broad talking points that are publicly available on the website are acceptable to talk about.

So, full disclosure, this was my second attempt, having failed it in mid April. I had been working exclusively in the AWS cloud for about a year and a half. My downfall was being over confident and overlooking the importance of certain topics I had not had much experience with. The [exam guide](https://d0.awsstatic.com/training-and-certification/docs-sa-assoc/AWS_certified_solutions_architect_associate_blueprint.pdf) has a list of topics on the exam. Here's my thoughts on each topic.

## AWS Knowledge

* In my opinion, you NEED to have real world experience to pass this exam. It wouldn't be impossible to do it on your own, but the depth of knowledge gained on the job will give you much more confidence. I passed the exam with around 2 years day to day experience with AWS.
* You need to understand the basic concepts of elasticity, scailibility and loose coupling of services. These are covered in the [AWS Whitepapers](https://aws.amazon.com/whitepapers/) which are (in my opinion) very readable.
* A good understanding of the difference between security groups and VPC ACL's is vital.

## General IT Knowledge

* You shouldn't be taking this exam if you don't have a general understanding of how computers and networking works. I recommends the CompTIA A+ and CompTIA Network+ exams if your still shaky on these topics.
* Knowing the conceptual difference between load balancers, server caching (Memcache/Redis), web servers, relational databases and NoSQL is vital. Knowing when you use these components and how you benefit from them is the basis of almost all the things you do in the cloud.
* Understanding the different consistency models is very important to understanding replication and object storage on S3. You can find a good intro to this [here](http://cloudacademy.com/blog/consistency-models-of-amazon-cloud-services/).
* Understand the basics of what a CDN is and how it can help your latency. CloudFront is intergrated well with S3, so it's easy to get up and running.
* You will need to know the basics of networking: Private subnets, public subnets, routes, gateways, HTTP, NAT and DNS.
* Knowing how to use web API's and understand JSON is important too. Having a programming language that you can use to manipulate these API's will be helpful, but not required. If you don't know one, Python and the [requests](http://docs.python-requests.org/en/master/) library are my recommendations.

# Some General Tips

* Make sure you have a full understanding of the basic setup of EC2, RDS and S3. You don't need to know CloudFormation for the Associate exam, but when you come to use AWS, I recommend you provision everything via CloudFormation.
* Make sure you have a good understanding of VPCs, routes, NAT Gateways and Internet Gateways. This was a topic I was weak on with my first exam attempt because I don't recreate and design these components often.
* Know the different S3 storage classes and the availability and durability of each (along with knowing the difference between availability and durability).

# Exam Day

My exam centre was about an hour drive away. After signing some paperwork and handing over my 2 forms of ID, I was sat down at a computer. The exam is multiple choice, so you can usually eliminate one of two options. You can mark any questions you want to return too and go back over them at the end. I ended up with about 20 mins to go over 10 or so questions I marked, leaving about half as a guess by the time I clicked to complete the exam.

Once you gain your certification, it's valid for 2 years. You can go on to renew this by taking the same level exam again, or go on to the Professional level. This will be my route in the future.
