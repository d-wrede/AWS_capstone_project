# Title: Personal Portfolio and Chatbot for Job Hunting

## Overview

The project aims to create a personal portfolio website showcasing the user's CV, skills, projects, and GitHub profile to potential employers. Additionally, the website will incorporate a Chatbot powered by ChatGPT API to assist potential employers in evaluating the user as a candidate for job positions. The chatbot will have access to the user's CV information, skills, and project details to provide informed answers.

## Use Case

Potential employers visit the user's personal portfolio website to learn more about their background, experience, and skills. Employers can interact with the Chatbot to ask questions about the user's suitability for specific job roles, technical abilities, and past experiences. This interaction allows potential employers to quickly assess the user's fit for their company and positions without needing to contact the user directly.

## AWS Infrastructure

- Amazon S3: To store the static content of the portfolio website, including HTML, CSS, JavaScript files, and images.
- Amazon API Gateway: To create and manage the RESTful API for the ChatGPT integration, enabling communication between the user interface and the backend Lambda functions.
- AWS Lambda: To handle the ChatGPT API requests, process user inputs, and return responses to the website in real-time.
- AWS Certificate Manager: To provide an SSL/TLS certificate for securing the website with HTTPS.
- Amazon CloudFront: To distribute the static content and API responses globally using a content delivery network (CDN), improving performance and security.
- Amazon Route 53: To manage the domain name and DNS records, pointing the domain to the appropriate AWS resources, such as CloudFront distributions.

Infrastructure as Code (IaC) will be utilized to automate the provisioning and management of the AWS infrastructure, ensuring repeatability and version control. Optional features that can be incorporated to further showcase the user's skills include CI/CD pipelines, monitoring and logging, security best practices, and automated security scanning.

This simplified infrastructure will offer a cost-effective solution for hosting the portfolio website while leveraging AWS services for a responsive, secure, and user-friendly experience.
