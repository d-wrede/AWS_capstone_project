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

Checking bucket endpoints:

| Bucket name     | Endpoint                                                       | ARN                          | Static website hosting |
|---------------------|----|---|---|
| daniel-wrede.de | <http://daniel-wrede.de.s3-website.eu-central-1.amazonaws.com> | arn:aws:s3:::daniel-wrede.de | Enabled                |
| www.daniel-wrede.de | <http://www.daniel-wrede.de.s3-website.eu-central-1.amazonaws.com> | arn:aws:s3:::www.daniel-wrede.de | Enabled    |

Comparing 