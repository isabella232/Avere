# Using Multiple Azure Subscriptions

There are a number of reason you may want to use multiple Azure subscriptions in your deployments, e.g. separte billing for projects, or different billing by region. This example outlines how to deploy in different subscriptions, share an ExpressRoute circuit across subscriptions, and covers aspects of managing costs and balancing jobs between subscriptions.

Architecturally, a multi subscription deployment will not look different than adding a new region to your deployment.

[multi-sub architecture]

The difference is only in how resources are managed, in the architecture above, the Virtual Network A is deployed and managed by Subscription A. Resources (e.g. Virtual Machine, ExpressRoute Gateway) associated with Virtual Network A are also deployed and managed by Subscription A. Similarly, Virtual Network B is deployed and managed by Subscription B, as are associated resources (e.g. Virtual Machines, ExpressRoute Gateway). 

TODO:

 - Architecture diagram
 - Sample TF deployment
 - Billing examples
 - Switch option to compare prices in two regions (deploy to a specific subscription based on which is cheaper)
    - Retail Prices API
    - TF subscription selection