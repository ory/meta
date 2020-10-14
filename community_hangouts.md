# 07_10_2020 (first hangout)

## Q&A

### Question

#### ORY Product: Oathkeeper, Keto

#### Is there any way that we can change the Oathkeper flow?

### Answer

Write a pull request that submits the organizational structure that could be part of Keto. It might be easier to ask for all the logic to be supported in Keto.

Look if Keto can support what you are looking for and if it does not support that then make a feature request. Easier to pull off outside of Kratos.

### Answer

It should be possible, it should be a feature in Oathkeeper. If it is not possible please open a feature request; it is a very common/good use case.

---

### Question

#### ORY Product: Oathkeeper

#### Will there be multi domain support and multi domain login persistence?

### Answer

That is definitely something we are looking at. We need to figure out how to implement this safely though. It will be a lot of work but it would be a very important feature for us to have.

---

### Question

#### ORY Product: Hydra

#### What is the reasoning between having two database tables? Would it not be easier to merge the tables into one ? What is the design decision behind that?

---

## Comments

Comments/Feedback/Future Issues

# 07_10_2020 (second hangout)

## Q&A

### Question

#### How do you generally approach a migration path, what can consumers of this library expect?

### Answer

We have extensive documentation on any breaking changes, if you sign up to the newsletter you will get notified every time there is a new release.

We have elaborate descriptions of all changes in the newsletter, or on github. The changelogs are in the documentation and also on github. Also with guides how to do the upgrade/migration.

With helm charts its a manual process changing the version number at the moment. We are looking to automate this in the near future.

[k8s issue #180](https://github.com/ory/k8s/issues/180)

---

### Question

#### ORY Product: Kratos, Hydra, Oathkeeper

#### Do you have plans to offer support the open source, selfhosted deployments?

We have been using Oathkeeper & Kratos for Auth.
We are interested in support, but our customers dont allow SaaS in this regard.

### Answer

We will focus on the cloud offering, it is easy to scale, easier to support.
But this request comes often, and we do want to help companies in this position.

We do want to offer solutions there so we could provide you with support in the future.
Best solution: Talk to [jared](jared@ory.sh), figure out what you need and we will find a solution.

---

### Question

#### ORY Product: Hydra

#### Is there a config to have Hydra respond to /api/hydra for example?

I am deploying Hydra in Docker in AWS.
I cant configure it to respond to a specific URL, without route URL.

### Answer

Solution here is reverse proxy, like Oathkeeper.

If you do not use a reverse proxy, you have to do it with path rewrite currently.

---

### Question

#### Will ORY open source stay open source or become proprietary?

### Answer

All projects that are currently open source, will remain open source.
We have a commitment to open source, that we still need to publish.

We will not go down the path of ElasticSearch. The monetization strategy that we are following is running all the software as one consistent product with alot of additional benefits as a cloud service.

But the core building blocks will remain free and open source. As we use Linux and Kubernetes, we also use the ORY stack - which is open source.

We are also planning on having a foundation of sorts, but this is still in planning.

---

## Comments

Comments/Feedback/Future Issues

### Comment

Next big assignment for Patrick is implementation of Google Sansibar paper. This will allow us to deploy multi-region without significant latency.
