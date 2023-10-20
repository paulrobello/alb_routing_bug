## This repo reproduces a bug with ALB route conditions in localstack pro

Bug Report: 
[https://github.com/localstack/localstack/issues/9395](https://github.com/localstack/localstack/issues/9395)

### It requires that you run it inside [https://github.com/devxpod/GDC](https://github.com/devxpod/GDC)

The primary reason for the GDC is that it allows your testing container to run with Localstack DNS enabled without having to make any changes to host DNS.

* Clone the GDC and set it up per its readme.
* Ensure your localstack pro key is setup with the GDC or exported to your current environment.   
* **Change to the folder where you cloned this repo.**

**Start the gdc:**  
```bash
run-dev-container.sh
```

**In a separate terminal run:**  
```bash
docker exec -it alb-dev-1 bash -l
```

**Inside the GDC terminal you just opened run:**  
```bash
make it-again
make exec-api-all
```

This will clear out existing deployment, deploy stack and run tests.

You will see that each time you run the "**it-again**" target it will cause "**exec-api-all**" target to get different outputs.  
Rarely are they the correct outputs.

Expected output: 

```text
Expected: "Route1"          Got: "Route1"
Expected: "Route2"          Got: "Route2"
Expected: "404 not found"   Got: "404 not found"
```

Actual output (will be random and most likely wrong):

```text
Expected: "Route1"          Got: "404 not found"
Expected: "Route2"          Got: "Route1"
Expected: "404 not found"   Got: "Route1"
```


## CODE
**/iac/alb.tf** creates the ALB and makes use of 2 modules. One for creating lambdas and one for creating routes for the ALB.

The code that triggers the bug is located in **/iac/aws/alb/route/main.tf**

Bug is triggered when multiple listener rule conditions are specified.