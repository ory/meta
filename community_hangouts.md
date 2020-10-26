# 07_10_2020_01

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

<<<<<<< Updated upstream
## Comments

Comments/Feedback/Future Issues

---

=======
>>>>>>> Stashed changes
# 07_10_2020_02

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

### Comment

Next big assignment for Patrick is implementation of Google Sansibar paper. This will allow us to deploy multi-region without significant latency.

---

# 14_10_2020

## Q&A

### Question

#### ORY Project: Oathkeeper

#### My biggest concern is this big refactor on Oathkeeper concerning the Hydrator, for example [Issue 441](https://github.com/ory/oathkeeper/issues/441)

### Answer by Aeneas

So the original hydrator was more or less like an interim solution for the project and the idea was always to have a pipeline where you do authentication, hydration, authorization and then mutation.

So you've probably looked into the configuration system for remote Json, for example, and I think its ultimately really not great to generate Json.
So we want to use JsonNet for all of the config stuff. And with the change we would also introduce a new part to the pipeline, which would then be a dedicated hydrator because I think it makes a lot of sense to add. Basically you get the requests and then authenticate, add context, check for permissions and then you take all of the data, massage it and put it into a token or something.

---

### Question

#### ORY Project: Kratos

#### When are you expecting to release the 0.5 version of Kratos?

### Answer

The way we do release is slow because the pipelines sometimes a little bit flaky when it comes to releases as we do pre-releases. So we do for example the pre-release where we see if all the pipelines are working, if the build is successful and if all the tests are successful for the build pipeline, the binary in a Docker image ect.

If that works and once that passes all tests we do the proper release. So the fact that you're seeing the pre dot 0 release is a very good sign because it means that we're working on it.
Unfortunately the build didn't pass so so we will be trying to figure out what's going on.

You can expect the release maybe in the next hours, definitely this week. It depends how difficult it is to figure out what's going on.

---

### Question

#### ORY Project: Kratos

#### Is there any way to specify the schema_id to render the proper form inputs which belong to the specified schema?

For example I have an employee and customer schema and I would like to be able to specify the schema when registering a new account from the selfservice endpoints or public API or anywhere else where I can create a user.

More info in [this thread](https://community.ory.sh/t/multiple-schemas-identities-seem-problematic/2251)

### Answer

So for registration, it's a little bit difficult because assume you have customer schema and you have a admin schema.
You don't really want someone who signs up to be able to use the admin schema because they're not a regular user or customer.

I think the best idea probably would be to create an issue in the Kratos repo and explain the use case and then we can discuss some ideas.

Connected Issue: [kratos #765](https://github.com/ory/kratos/issues/765)

---

<<<<<<< Updated upstream
## Comments

Comments/Feedback/Future Issues
=======
# 21_10_2020

## Q&A

### Question

We had to get used to the terminology and what all the different systems do because there's quite a lot to the ecosystem. Could you give me a broad overview?


### Answer 

We started out with Hydra, which is the protocol layer for open authorization and open ID connect. 
And the reason we started there was that we were doing a cloud native file sharing application at the time and it just got really difficult to interface with Dropbox and Google Cloud and so on. The Go Community was not so so big back then and we just wanted to do something that would be good for Go developers to use. 

But the deeper you get into open authorization and OAuth and OpenID Connect the more complex it gets, the terminology, the structure of things, the processes or flows. So we ended up completely redoing Hydra two times just because the more we got into it, the more we knew and learned. 

Then probably the best place to start is with Kratos, which is how you build your credentials, your username, password and all the flows around that. 

Alot of companies don't need auth and open ID connect because they're not using cloud native services. 
So here Kratos is a great fit. I think it's really an amazing utility, that we're soon going to offer as a cloud service also, by the way. Then Hydra I just explained that, and also we have oathkeeper.
Oathkeeper is an implementation of Google beyondcorp reverse proxy plus some rules about how and why to access API, so when you use Json web tokens against an API for OAuth, there's a number of rules etc. 
It could be in the payload or it could be just general rules about API access that you want to implement, so that's a zero trust API access infrastructure. 

And last but not least there are different models out there for role-based access management. For instance ORY Keto is an implementation basically mimicking the AWS IAM. And now if you look at the newest sort of PR in the Keto project we are tackling this at a much bigger level and implementing or trying to implement something that Google calls Zanzibar, which is a more sort of very low latency access management and role-based control system. So you write the rules and we basically create an infrastructure that lets you manage that at planet scale. 

---

### Question

We are reading that jobs in Kratos are not being encouraged anymore. Why is that?

### Answer

The reason for that is it's Hydra uses a special flavor of jobs before you get to the API. The reason for that is to obfuscate some information and also make it more compatible with some of the other security approaches we have including oathkeeper, but when it's through the API it then turns into a normal Json web token.
So these are Open Standards, but they give you a lot of, let's say flexibility, especially on how you want to configure the payload. 

nd they have a very simple structure, there's a record for how it's been made, what algorithm the payload uses and the signature and we're not going to stray far away from that at all because that's how you guarantee interoperability amongst different systems.
So we do take some liberties within Hydra of making those tokens as it's called "ORY flavoured" until they get to the API.

There's also some situations where it's not recommendable to use jobs. There's actually lots of situations just because it's a new area and it's emerging. And you know, there is not enough implementation experience with it. 

So if you have architectural questions and you want to ask them, you can do that an issue or something else but be confident that we've had tons of conversations about this and the implementation of Hydra is now over five years old.

---

### Question

Our main fear is that you guys might be closing or changing all the Open Standards to some closed standard of security authorization.

### Answer by Thomas

We're not interested in violating those standards actually in any way because that's the whole basis of our work too. 
I mean the IEEE standard and the IETF standard and the w3c standard are our standards. That doesn't mean that the ORY projects implement everything and by the way we implement a lot of things based on how companies are using these things, but when we implement it it is exactly in accordance with the standard.
And the ORY open source projects too are the codebase from that we build our products, so we are relying on them to stay open source. 

## Comments

---

>>>>>>> Stashed changes
