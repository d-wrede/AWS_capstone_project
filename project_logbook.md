# Project Logbook

## 25. of April

- S3 Bucket Setup:
    
    Created an S3 bucket to host a static website on AWS.
    Configured the bucket's properties to enable static website hosting.
    Set up a bucket policy to allow public read access to the objects in the bucket.

- Website Deployment:
        
    Created a GitHub repository to store the website files.
    Set up a GitHub Actions workflow using a YAML file (s3_deploy.yml) to automate the deployment process.
    Used the AWS CLI within the workflow to sync the local files to the S3 bucket.

- Self-hosted Google Fonts:
    Identified the usage of Google Fonts by checking the HTML files for links to fonts.gstatic.com and fonts.googleapis.com.
    Downloaded the required font files (Open Sans and Poppins) from Google Fonts.
    Added the downloaded font files to the website's file structure.
    Created the appropriate @font-face declarations in the CSS file, linking to the locally hosted font files.
    Removed the external Google Fonts links from the HTML files.

- Testing and Verification:
    Checked the website to ensure that it's working correctly and using the self-hosted fonts.
    Used Google Chrome's Developer Tools to verify that the font requests were being made to the local files hosted on the S3 bucket.

With these steps, the website has been successfully deployed to an S3 bucket, and Google Fonts have been self-hosted to improve performance and privacy for visitors.

## 26. of April

- Discovered a guide for setting up an S3 bucket static website: https://www.alexhyett.com/terraform-s3-static-website-hosting/
- Noted that the guide is outdated and requires several additional resources: aws_s3_bucket_website_configuration, aws_s3_bucket_policy, aws_s3_bucket_ownership_controls, aws_s3_bucket_public_access_block, and aws_s3_bucket_acl
- Identified the "url_redirects" module from "operatehappy" as a potential solution for implementing redirection using just a single bucket, thereby eliminating the need for a second bucket.
- Explored other potentially relevant Terraform modules, such as the "static_website" and "s3_static_website" modules. However, due to unclear documentation, decided to return to the original guide for guidance.


- CloudFront Setup:
    Configured a CloudFront distribution using Terraform to serve the static website from the S3 bucket.
    Set up the CloudFront distribution to use the custom domain name.
    Enabled HTTPS by using AWS Certificate Manager (ACM) to create an SSL certificate for the custom domain.
    Configured CloudFront to redirect HTTP requests to HTTPS.
    Set custom error responses in the CloudFront distribution to handle 404 errors.

- Route 53 Configuration:

    Modified the Terraform code to use the existing Route 53 hosted zone for the custom domain.
    Created Route 53 records to point the custom domain and its "www" subdomain to the CloudFront distribution.

- SSL Certificate:

    Requested an SSL certificate using AWS Certificate Manager (ACM) with Terraform.
    Used the "EMAIL" validation method to validate the domain ownership.
    Configured the CloudFront distribution to use the SSL certificate for serving content over HTTPS.
    Waited for the validation email to arrive and confirmed the domain ownership.

- GitHub Actions Workflow Update:

    Updated the GitHub Actions workflow to include AWS CLI v2.
    Added a step to create an invalidation in CloudFront to clear the cache whenever the website files are updated.

- Testing and Verification:

    Checked the website using the custom domain to ensure it's working correctly and served over HTTPS.
    Verified that the CloudFront distribution is serving the content and handling custom error responses.
    Tested the GitHub Actions workflow to ensure the CloudFront cache is invalidated upon deployment.

- Cross-Origin Resource Sharing (CORS) and why it's advisable to implement it when using Amazon CloudFront for a web portfolio
- Best practices for handling both the "www" and non-"www" versions of a domain in a static website hosted on AWS S3
- How to set up URL redirects within a single S3 bucket using the operatehappy/s3-object-url-redirects/aws module
- How to redirect all requests without 'www' to the domain name with 'www' using a single S3 bucket in combination with the operatehappy/s3-object-url-redirects/aws module.
- Domain registration and WHOIS records
- AWS Route 53 for domain management and DNS
- SSL/TLS certificates and AWS ACM
- SSL certificate validation methods (Email and DNS)
- AWS S3 for object storage
- AWS CloudFront for content delivery and CDN
- Terraform IaC for AWS resource provisioning
- AWS IAM for access management
- Troubleshooting SSL certificate validation issues


## 27. of April

- succeeded receiving the SSL certificate using DNS verification
- homepage is accessible via 'www.daniel-wrede.de'
- unfortunately not via 'daniel-wrede.de':

    ```This XML file does not appear to have any style information associated with it. The document tree is shown below.
    <ListBucketResult>
    <Name>daniel-wrede.de</Name>
    <Prefix/>
    <Marker/>
    <MaxKeys>1000</MaxKeys>
    <IsTruncated>false</IsTruncated>
    </ListBucketResult>```

Route 53 records in hosted zone:

| Record name         | Type | Routing policy | Alias | Value/Route traffic to         | Evaluate target health |
|---------------------|------|----------------|-------|--------------------------------|------------------------|
| daniel-wrede.de     | A    | Simple         | Yes   | d1bmb6uxa1880d.cloudfront.net. | No                     |
| www.daniel-wrede.de | A    | Simple         | Yes   | dvuu6a5xq7plk.cloudfront.net.  | No                     |


Cloudfront distributions:

| ID            | Domain name                   | Alternate domain names | Origin name            | Origin domain                                     | Status  |
|---------------|-------------------------------|------------------------|------------------------|---------------------------------------------------|---------|
| EL0ZM13SZXHCM | d1bmb6uxa1880d.cloudfront.net | daniel-wrede.de        | S3-daniel-wrede.de     | daniel-wrede.de.s3.eu-central-1.amazonaws.com     | enabled |
| E306BUV4ZIP4WY | dvuu6a5xq7plk.cloudfront.net | www.daniel-wrede.de    | S3-www.daniel-wrede.de | www.daniel-wrede.de.s3.eu-central-1.amazonaws.com | enabled |

Comparing the Route53 and Cloudfront tables:

| Alternate domain names | daniel-wrede.de                  | www.daniel-wrede.de           |
|------------------------|----------------------------------|-------------------------------|
| Value/Route traffic to | d1bmb6uxa1880d.cloudfront.net.   | dvuu6a5xq7plk.cloudfront.net. |
| Domain name            | d1bmb6uxa1880d.cloudfront.net    | dvuu6a5xq7plk.cloudfront.net  |

Domain name from 'daniel-wrede.de' is not accessible, i.e. leads to the same error page.

Checking s3 bucket data:

| Bucket name     | Endpoint / Regional domain name | ARN                          | Static website hosting |
|---------------------|--------------------|---|---|
| daniel-wrede.de |   <http://daniel-wrede.de.s3-website.eu-central-1.amazonaws.com> | arn:aws:s3:::daniel-wrede.de | Enabled                |
| www.daniel-wrede.de |   <http://www.daniel-wrede.de.s3-website.eu-central-1.amazonaws.com> | arn:aws:s3:::www.daniel-wrede.de | Enabled    |

Comparing Cloudfront and s3 bucket tables:

| Bucket name    |  daniel-wrede.de | www.daniel-wrede.de |
|----------------|------------------|----------|
| Cloudfront Origin domain | daniel-wrede.de.s3.eu-central-1.amazonaws.com | www.daniel-wrede.de.s3.eu-central-1.amazonaws.com |
| Bucket Endpoint | <http://daniel-wrede.de.s3-website.eu-central-1.amazonaws.com> | <http://www.daniel-wrede.de.s3-website.eu-central-1.amazonaws.com> |

The Cloudfront origin domains are different from the bucket endpoints. The reason is that the Cloudfront origin domain uses the non-website (regional) domain names, while the given bucket endpoints are global. According to this [statement on stackoverflow](https://stackoverflow.com/questions/65142577/is-cloudfront-origin-using-s3-global-domain-name-performing-better-than-regional), this setup is correct and these two addresses/names serve different purpose. The non-website (regional) domain name is the fast way for Cloudfront to access the bucket, while the global bucket endpoint is the access point, if anybody wants to access the bucket (from anywhere) via browser.

Overview of todays tasks and challenges:

- Request SSL certificate via DNS verification:

    Discussed the process of requesting an SSL certificate through Amazon Certificate Manager (ACM) to secure a custom domain.
    Validated ownership of the domain using DNS verification by creating a CNAME record in Route 53. ACM provided the name and value for the CNAME record.
    After successful validation, ACM issued the SSL certificate, which can be used with CloudFront distributions to enable HTTPS for the website.

- Troubleshooting connecting without 'www' to the website:

    Investigated the issue of not being able to access the website without the 'www' prefix and reviewed the setup of Route 53, CloudFront distributions, and the S3 bucket redirection.
    Confirmed that the Route 53 records were correctly set up to point to the corresponding CloudFront distributions.
    Verified the CloudFront distributions were properly configured to use the correct S3 buckets as their origins.
    Reviewed the S3 bucket setup, ensuring that the redirect bucket was configured to redirect requests to the 'www' version of the domain.

- Objective: To create a table with expandable cells, where the first three lines of each cell are visible initially. Upon clicking on a cell, the full content is shown, and clicking again hides the full content and shows the initial preview.

    HTML Updates: Modified the table structure by adding a data-toggle attribute to each cell in the collapsible row. Wrapped the first three lines (preview content) in a div with the preview class. Wrapped the content to be shown or hidden in a div with an ID matching the data-toggle attribute and a class of collapsible-content.
    JavaScript Updates: Created a toggleRow function that handles the click event on the table cells. The function retrieves the data-toggle attribute from the clicked cell, finds the content div with the matching ID, and toggles the collapsible-content and hidden classes on the content div and clicked cell, respectively.
    CSS Updates: Added a style for the hidden class to hide the preview content when the full content is expanded.
    Implementation: Integrated the toggleRow function in the scripts.js file and added an onclick attribute to the collapsible row in the HTML file, passing the event object to the toggleRow function.

## 28. of April

- Enable Route 53 Query Logging and CloudFront Access Logs: Set up logging to diagnose issues with accessing your website through Route 53 and CloudFront.

- Analyze Route 53 Query Logs: Examine the logs in Amazon CloudWatch to identify DNS queries, status codes, client IPs, and response times to understand the requests being made to your domain.

- Analyze CloudFront Access Logs: Download log files from the Amazon S3 bucket and review them to understand HTTP requests, response codes, edge locations, and cache hit/miss status for CloudFront. This helps to identify potential issues and optimize website performance.

    ```2023-04-28 09:42:01 FRA56-C1 0 95.208.248.193 GET d1bmb6uxa1880d.cloudfront.net /favicon.ico 000 http://daniel-wrede.de/ Mozilla/5.0%20(Macintosh;%20Intel%20Mac%20OS%20X%2010.15;%20rv:109.0)%20Gecko/20100101%20Firefox/112.0 - - Error 7wT5X5JHwtL0gNOtUnLuHVxxIJQdAE1OXzUfCeLc_7ayLN3tC6NgaA== daniel-wrede.de http 308 0.008 - - - Error HTTP/1.1 - - 4910 0.000 ClientCommError - - - -```

- The caching settings for my CloudFront distribution were adjusted to improve website performance and reduce the load on my origin server. The following steps were taken:

    The website's traffic patterns and performance needs were reviewed to identify areas for improvement.
    The cache behaviors for the CloudFront distribution were adjusted to reduce the number of requests to the origin server and increase the cache hit rate. Appropriate TTLs were set for different types of content, and gzip compression was enabled.
    The origin for the CloudFront distribution was updated to point to a redirect bucket that would redirect requests to the main website bucket.
    Testing was conducted to ensure that the updated settings were working as expected and that the website was still functioning correctly.
    Monitoring of the CloudFront distribution's performance and traffic was conducted to ensure that the new caching settings were working as expected, using CloudWatch metrics and other monitoring tools.
    The caching settings were adjusted as needed based on the website's traffic patterns and performance needs.

- An assessment was made to determine whether it is necessary to request visitors' consent for the use of cookies on a static website hosted on an S3 bucket. The Firefox developer tools were utilized to examine network requests and the storage inspector to identify any stored cookies. After a thorough analysis, it was found that no cookies were being used on the website. Consequently, the decision to request visitors' consent for cookie usage may not be required. However, ongoing reviews of any third-party services or scripts utilized on the website will be conducted to ensure compliance with relevant data protection laws.
- The reason for a second s3 bucket is due to search engine optimization 'does not like' two domains pointing to the same content. More information about the setup with two s3buckets are found in this [stackoverflow post](https://stackoverflow.com/questions/37000416/how-to-redirect-non-www-to-www-in-aws-s3-bucket-and-cloudfront#37026855).
- found this [AWS official post](https://aws.amazon.com/blogs/aws/root-domain-website-hosting-for-amazon-s3/)  and [this](https://docs.aws.amazon.com/AmazonS3/latest/userguide/website-hosting-custom-domain-walkthrough.html) to set up the dns redirection and compared to my infrastructure. It's all done accordingly.


- Reconsidered the use of website_endpoint, bucket_domain_name or bucket_regional_domain_name for the origin_name in the cloudfron distribution. And, as stated on terraform.io, the 'bucket_regional_domain_name' is correct to use: <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution>

    But somewhere, either on terraform or AWS side, there's pretty much confusion about the definition of these terms. I found this information in the AWS Management Console, when setting up a CloudFront distribution:

    ```"This S3 bucket has static web hosting enabled. If you plan to use this distribution as a website, we recommend using the S3 website endpoint rather than the bucket endpoint."```
    
    And it should look like this: daniel-wrede.de.s3-website.eu-central-1.amazonaws.com

    So, they recommend the s3 website endpoint, which, in terraform would be "daniel-wrede.de.s3-website.eu-central-1.amazonaws.com", while the "bucket_regional_domain_name", or better said, the "aws_s3_bucket.redirect_bucket.bucket_regional_domain_name" is in terraform "daniel-wrede.de.s3.eu-central-1.amazonaws.com". Since this is pretty confusing, I will step through each definition and present it in a table:

| Name / Term | Value |
|-------------|-------|
| AWS S3 website endpoint | daniel-wrede.de.s3-website.eu-central-1.amazonaws.com |
| AWS bucket endpoint | daniel-wrede.de.s3.eu-central-1.amazonaws.com |
| aws_s3_bucket.redirect_bucket.website_endpoint | daniel-wrede.de.s3-website.eu-central-1.amazonaws.com |
| aws_s3_bucket.redirect_bucket.bucket_regional_domain_name | daniel-wrede.de.s3.eu-central-1.amazonaws.com |
| aws_s3_bucket.redirect_bucket.bucket_domain_name | daniel-wrede.de.s3.amazonaws.com |

So as you can see, I confused it myself. The website endpoint in AWS is (luckily) identical with the website_endpoint in Terraform.

Also it is important to notice, that this is a special case for static website hosting. That is why the information shared in [this stackoverflow thread](https://stackoverflow.com/questions/65142577/is-cloudfront-origin-using-s3-global-domain-name-performing-better-than-regional), considering the S3 regional domain name ```{bucket-name}.s3.{region}.amazonaws.com``` instead of the global domain name ```{bucket-name}.s3.amazonaws.com``` is not applicable in this case.

Now let's look at the setup. According to above AWS statement, they recommend using the S3 website endpoint. According to terraform.io (link given above), the resource should be defined using the 'bucket_regional_domain_name', which is ```domain_name = "daniel-wrede.de.s3.eu-central-1.amazonaws.com"```. And when looking at the CloudFront distribution in the AWS Management Console, the Origin Domain is set to "daniel-wrede.de.s3.eu-central-1.amazonaws.com". This is clearly against the recommendations of AWS. I will attempt setting up the CloudFront distribution in the AWS Management Console, instead of using Terraform.


## 29th of April

I was finally able to make it work. Understanding, that the Terraform setup is not viable for static website hosting, using an s3 bucket. Since there's been an update to the Terraform CloudFront distribution resource, the regional domain name of the bucket is used as 'domain_name', in the AWS Management Console entitled as 'Origin domain', instead of the website endpoint. When attempting to use the s3 bucket for website hosting, this can become an issue, since features like website redirection may not be supported. The resulting behaviour is, that the website is only reachable via its' subdomain name 'www.daniel-wrede.de', but not via 'daniel-wrede.de' - which means, that the redirection does not work. When attempting to enter the website via a browser (Mozilla Firefox, in my case), the following message is shown:

    This XML file does not appear to have any style information associated with it. The document tree is shown below.
    <ListBucketResult>
    <Name>daniel-wrede.de</Name>
    <Prefix/>
    <Marker/>
    <MaxKeys>1000</MaxKeys>
    <IsTruncated>false</IsTruncated>
    </ListBucketResult>

This is also visible, when entering ```curl -v <https://daniel-wrede.de>``` into the terminal. The essence is shown and described here step by step:

- Connection established: The connection to daniel-wrede.de (IP address: 18.66.97.129) is successful on port 443, which is the default port for HTTPS connections.

      *   Trying 18.66.97.129:443...
      * Connected to daniel-wrede.de (18.66.97.129) port 443 (#0)

- TLS handshake: A successful TLS handshake occurs, ensuring secure communication between the client and the server. The connection uses TLSv1.3 with the cipher suite AEAD-AES128-GCM-SHA256.

      * SSL connection using TLSv1.3 / AEAD-AES128-GCM-SHA256

- Server certificate: The server's SSL certificate is valid, issued by Amazon, and matches the domain name daniel-wrede.de.

      *  subject: CN=daniel-wrede.de
      *  start date: Apr 27 00:00:00 2023 GMT
      *  expire date: May 25 23:59:59 2024 GMT
      *  subjectAltName: host "daniel-wrede.de" matched cert's "daniel-wrede.de"
      *  issuer: C=US; O=Amazon; CN=Amazon RSA 2048 M02
      *  SSL certificate verify ok.

- HTTP/2: The server supports HTTP/2, which enables faster and more efficient communication compared to HTTP/1.1.
 
      * Using HTTP2, server supports multiplexing

- Request: A GET request is made to the root path (/) of the domain.

        > GET / HTTP/2
        > Host: daniel-wrede.de

- Response: The server responds with a 200 status code, indicating a successful request. The content-type header indicates that the response body is an XML document.

        < HTTP/2 200 
        < content-type: application/xml

- Amazon S3 server: The response headers reveal that the server is AmazonS3, and the S3 bucket is hosted in the eu-central-1 region.

        < x-amz-bucket-region: eu-central-1
        < server: AmazonS3

- CloudFront cache status: The response was not served from CloudFront's cache and is a cache miss.

        < x-cache: Miss from cloudfront

- Response body: The XML document in the response body suggests that the S3 bucket is publicly accessible and returning a bucket content listing instead of the desired index.html file. This is the xml file, shown in the browser.

        <?xml version="1.0" encoding="UTF-8"?>
        <ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>daniel-wrede.de</Name><Prefix></Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated></ListBucketResult>%

The most important from this response is, that the request is answered with a status code of 200, which means 'okay', and a list of the bucket content is sent as a reply. The bucket is empty. This indicates, what was already stated in the beginning, that the request has been forwarded to the regional domain name and therefore treated as a kind of 'read bucket files request', instead of a website request. **Expecting a response with status code 301, this is not the desired response.** This response is also accessible via an internet browser, inspecting the network responses.

Eventually there is a setup that works with Terraform, but I solved it (for now) by reconfiguring the 'domain_name'/'origin domain' in the CloudFront Management Console from using the regional domain name 'daniel-wrede.de.s3.eu-central-1.amazonaws.com' to using the (regional) website endpoint 'daniel-wrede.de.s3-website.eu-central-1.amazonaws.com', as posted in the earlier statement of AWS:

![AWS website endpoint statement](AWS_website_endpoint_statement.png)

I have done this for both cloudfront distributions, since it seems to be the correct setup. This is the main step for enabling the redirection and making the website accessible via 'daniel-wrede.de'. For editing the origin settings, it is necessary to disable the cloudfront distribution. After enabling both distributions, the error still persists. First invalidating the cloudfront distributions, and thereby resetting their caches, finally enables the redirection properly, so when accessing 'daniel-wrede.de', getting redirected to 'www.daniel-wrede.de'. *Beautiful!*

## 2nd of May

- found new tutorial for a static website using s3 bucket setup: <https://medium.com/runatlantis/hosting-our-static-site-over-ssl-with-s3-acm-cloudfront-and-terraform-513b799aec0f>
- checked: it is not necessary to ask for cookie consent, since the homepage does not use cookies

## 3rd of May

- Managed to find a setup using the 'website_endpoint' directly in the cloudfront distribution configuration:

    ```terraform
    # It is necessary to use the website_endpoint here, since we are
    # redirecting to a website. Please ignore the related warning message
    # When encountering 'Error: Missing required argument' for 'origin_id'
    # reapplying the terraform should fix it
    domain_name = aws_s3_bucket.www_bucket.website_endpoint
    ```

- Following this official and recently posted doc for setting up the logging without using a public s3bucket: <https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html>

    According to that, since April 28th 2023 it is necessary to "enable S3 access control lists (ACLs) for new S3 buckets being used for CloudFront standard logs", as it says. This is done by using an [example from terraform.io](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl).

- checket license terms for the [website template](https://themewagon.com/themes/free-bootstrap-4-html-5-personal-portfolio-website-template-mark/) here: <https://themewagon.com/license/>
  
  It's free to use.

- now it's official - there is a bug in the cloudfront distribution resource, as described here:
  - <https://discuss.hashicorp.com/t/aws-cloudfront-origin-originname-bug/37997/4>
  - <https://www.reddit.com/r/Terraform/comments/114uem0/comment/j92kx8q/>

    Here I found the (implicit) solution to use the website endpoint given by the aws s3 bucket website configuration for the buckets, instead of using the bucket's own endpoints. And it works like a charme! **WHOOT!**

- Found an interesting repo for static website hosting using s3 bucket: <https://github.com/subaquatic-pierre/pwa-ci-cd>
- according to this AWS Guide on ["Getting started with a secure static website"](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/getting-started-secure-static-website-cloudformation-template.html), it is recommended using origin access identity for cloudfront accessing the s3 bucket, instead of setting it to "public read". But it seems to be slightly outdated, since there is something called Origin Access Control with more features, like enabling PUT and DELETE, as well as SSE-KMS. On another page it is recommended to use OAC. But here it is also stated that using either OAI or OAC for a cloudfront distribution that has a website endpoint as origin, is not possible:

    "Note
    If your origin is an Amazon S3 bucket configured as a website endpoint, you must set it up with CloudFront as a custom origin. That means you can't use OAC (or OAI). However, you can restrict access to a custom origin by setting up custom headers and configuring the origin to require them. For more information, see Restricting access to files on custom origins."

    This sounds contradicting to me, according to the clear recommendations using the website endpoint as origin, as we have covered earlier. I find such contradicting statements in [another AWS statement](https://repost.aws/knowledge-center/cloudfront-serve-static-website) and [on edureka](https://www.edureka.co/community/167779/how-can-i-restrict-access-to-an-s3-website-to-cloudfront?show=168219#a168219) as well.
    
    I see two options:
  1. Use the S3 bucket's website endpoint as the origin, recommended for taking advantage of S3 static website hosting features, such as index documents, error documents, and redirects. Then restrict access using a combination of bucket policies, ACLs, and custom headers.
  2. Use the S3 bucket (not the website endpoint) as the origin and restrict access using an Origin Access Identity (OAI). This option doesn't provide S3 static website hosting features but simplifies access control and security.
    
    Option 1 is chosen, to be able using the s3 bucket website features.

    This is an iterative process :-). Since so many sources recommend using a OAI for connecting the cloudfront distribution with the s3 bucket, also on many sites using the website endpoint, I gave it a try. This leads to the error message:

    ```
    Error: creating CloudFront Distribution: InvalidArgument: The parameter Origin DomainName does not refer to a valid S3 bucket.
    │       status code: 400, request id: caf3e0a6-61bf-4f95-b8cc-6eeff52af1f8
    │
    │   with aws_cloudfront_distribution.www_s3_distribution,
    │   on cloudfront.tf line 2, in resource "aws_cloudfront_distribution" "www_s3_distribution":
    │    2: resource "aws_cloudfront_distribution" "www_s3_distribution" {
    ´´´

    Hence I changed the domain name to the 'aws_s3_bucket.www_bucket.bucket_regional_domain_name', which is possible for the www_bucket, since we don't use redirection here.

Furthermore I gave it a try using custom headers. Here a header is specified in the bucket policy, so only messages containing that header are accepted:

```terraform
resource "aws_s3_bucket_policy" "give_read_access_to_www_bucket" {
bucket = aws_s3_bucket.www_bucket.id
policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.www_bucket.arn}/*"
        Principal = "*"
        Condition = {
        StringEquals = {
            "aws:Referer" = "X-CloudFront-Access"
        }
        }
    }
    ]
})
```

This works fine, using the 'aws_s3_bucket_website_configuration.www_bucket.website_endpoint' as domain name (and specifying the header in the cf distribution forwarded message). But this option is not secure, since anybody, who looks at the terraform code, will know the header and access the s3 bucket. I guess, since it only stores the website files, this is not crucial, but I wouldn't consider it being good practice. But regarding the many examples and hints towards OAI [like here](https://www.milanvit.net/post/terraform-recipes-cloudfront-distribution-from-s3-bucket/), and other examples not using such security protection at all, this seems to be of less importance.

### Note: The cloudfront logs are saved with several hours delay. But they are stored in the log bucket now. :-)

- www bucket (comprising the files): Uses CloudFront Origin Access Identity (OAI) to restrict access to the S3 bucket, providing a high level of security. However, this approach does not allow using S3 bucket website features. The bucket is not public.
- redirect bucket: Utilizes custom headers in the S3 bucket policy to restrict access only to the CloudFront distribution. This approach provides medium security since the header is stored in Terraform files, which may be publicly available on GitHub. Bucket access is limited to 'only authorized users of this account'. To improve security, consider using an Origin Access Identity for the redirect bucket as well.
- log bucket: Grants access to the S3 Log Delivery group via an Access Control List (ACL), ensuring a secure connection while using AWS services for logging purposes. This is a standard and secure way to grant access to AWS services.


## 4th of May

- These steps were taken to enable email services using Amazon Web Services (AWS). The main components involved in this setup include AWS Simple Email Service (SES), S3, Lambda, and Route 53.
  - followed these guides:
    - <https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/>
    - <https://docs.aws.amazon.com/ses/latest/dg/receiving-email-receipt-rules-console-walkthrough.html>
  - Configure AWS providers:
    - Set up AWS providers for the main region (eu-central-1), ACM (us-east-1), and SES (eu-west-1) in the Terraform configuration file.
    - Set up the email S3 bucket: Create an S3 bucket in the eu-west-1 region to store incoming emails.
    - Verify the domain in SES: Verify the domain (daniel-wrede.de) in the SES console (eu-west-1) to allow sending and receiving emails using the domain.
    - Configure DNS records: Create an MX record in Route 53 to route incoming emails to the SES service in the eu-west-1 region.
    - Create SES rule set and receipt rules: Configure a rule set in SES and create receipt rules to process incoming emails, such as saving them to the S3 bucket and invoking a Lambda function for email forwarding.
    - Set up the Lambda function: Create a Lambda function in the eu-west-1 region with a Python runtime and an associated IAM role.
    - Provide the Lambda function with necessary permissions to access the S3 bucket and use the SES service.
    - Configure the Lambda function's environment variables, including the S3 bucket name, email sender, email recipient, and region.
    - Write and deploy the Python code to handle email forwarding.
    - Configure the S3 bucket policy: Update the bucket policy to allow the SES service to put objects (emails) into the bucket.
    - Ensure that the Lambda function has the necessary permissions to access the objects in the bucket.
    - Test the email setup: Verify the email address used for sending emails (e.g., projects@daniel-wrede.de) and confirm the verification email sent by AWS. Test the email forwarding functionality by sending an email to the verified address and checking if it is correctly forwarded to the intended recipient.
  - Debugging the Lambda email forwarding issue:
    - Identified that the Lambda function was unable to access the S3 bucket containing the email.
    - Reviewed the IAM policies and S3 bucket policies to ensure proper access permissions.
    - Ensured the Lambda function was using the correct IAM role, LambdaEmailRole, and the bucket name was specified correctly in the Lambda function's environment variables.
    - Made sure the S3 bucket policy allowed the LambdaEmailRole to perform the s3:GetObject action.
    - Tested the Lambda function again, and it successfully forwarded the email as an EML file.
- found some expandable table templates giving better overview over my list of competences:
  - <https://mdbootstrap.com/docs/standard/extended/responsive-table/>
  - <https://stackblitz.com/angular/eaajjobynjkl?file=src%2Fapp%2Ftable-expandable-rows-example.html>
  - <https://adminlte.io/docs/3.1/javascript/expandable-tables.html>
  - <https://www.geeksforgeeks.org/how-to-make-html-table-expand-on-click-using-javascript/>
- implementing receipt rule set and receipt rules in terraform, using these AWS CLI commands to retrieve the configuration from the SES console setup used:

    ```bash
    aws ses list-receipt-rule-sets --region eu-west-1
    aws ses describe-receipt-rule-set --rule-set-name daniel-wrede.de --region eu-west-1
    ```
    
    Response:
    ```
    {
        "Metadata": {
            "Name": "daniel-wrede.de",
            "CreatedTimestamp": "2023-05-04T08:45:43.741000+00:00"
        },
        "Rules": [
            {
                "Name": "forward_mails",
                "Enabled": true,
                "TlsPolicy": "Optional",
                "Recipients": [
                    "daniel-wrede.de"
                ],
                "Actions": [
                    {
                        "LambdaAction": {
                            "FunctionArn": "arn:aws:lambda:eu-west-1:792277894863:function:EmailForwarder",
                            "InvocationType": "Event"
                        }
                    }
                ],
                "ScanEnabled": true
            },
            {
                "Name": "mails_to_bucket",
                "Enabled": true,
                "TlsPolicy": "Optional",
                "Recipients": [
                    "daniel-wrede.de"
                ],
                "Actions": [
                    {
                        "S3Action": {
                            "BucketName": "emails-daniel-wrede.de",
                            "ObjectKeyPrefix": "emails"
                        }
                    }
                ],
                "ScanEnabled": true
            }
        ]
    }
    ```

    Experiencing quite some trouble at setting up the lambda action for email forwarding in the receipt rule, receiving this error message:

    ```
    │ Error: updating SES Receipt Rule (manage-emails-rule): InvalidLambdaFunction: Could not invoke Lambda function: arn:aws:lambda:eu-west-1:792277894863:function:EmailForwarder
    │       status code: 400, request id: 67bcdb57-b306-468c-a621-78f1b791a3a9
    │
    │   with aws_ses_receipt_rule.rule,
    │   on ses.tf line 16, in resource "aws_ses_receipt_rule" "rule":
    │   16: resource "aws_ses_receipt_rule" "rule" {
    ```

    Setting up another receipt rule with the lambda action in the SES console works without issues. It is assumed being related to the 'aws_lambda_permission' resource. Attempting to 


## 5th of May

- browsing through the terraform modules and guides for static website hosting using s3, cloudfront and route53, I don't find any up-to-date solution using s3 website bucket redirection. They are either outdated, using the website endpoint as domain name, or only using one bucket. One such quite comprehensive module applying redirection, but unfortunately outdated, is found [here](https://github.com/7hoenix/terraform-website-s3-cloudfront-route53).
- continuing working on the receipt rule set, comparing the permissions to invoke the lambda function created via terraform with those created via SES console. Using the following AWS CLI command, a different ARN syntax has been detected and successful corrected:
  
    ```aws lambda get-policy --function-name EmailForwarder --query 'Policy' --output text --region eu-west-1 | jq .```

- encountering error from redirect_bucket policy:

    ```
    │ Error: Error putting S3 policy: AccessDenied: Access Denied

    │       status code: 403, request id: RB7J0MYG51H482K9, host id: CvRqCirGAE1GYRmdLSP0G1mA/pmEQvOdX53+Ua7S448Ye1HTyAYvVd7g9mhpGbyadPOrNtiJoZ8=
    │
    │   with aws_s3_bucket_policy.give_read_access_to_redirect_bucket,
    │   on s3_redirect_bucket.tf line 16, in resource "aws_s3_bucket_policy" "give_read_access_to_redirect_bucket":
    │   16: resource "aws_s3_bucket_policy" "give_read_access_to_redirect_bucket" {
    ```

    Stepped through older commits, terraform destroy and apply to find a working version. The commit (2 steps back) works, but with an aws_s3_bucket_acl.redirect_bucket instead of an aws_s3_bucket_policy.
