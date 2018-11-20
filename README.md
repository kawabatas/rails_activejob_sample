# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

RAILS_ENV=test bin/rails spec

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

gcloud app deploy --project XXX

* ...

## Example Usage

```
# unschedule job
curl "http://localhost:3000/activejobs/enqueue?job=SampleJob&name=hoge"

# schedule job
curl "http://localhost:3000/activejobs/enqueue?job=SampleJob&name=hoge&wait_minutes=1"
```

## Query Parameters Reference
- job - (Required) A Class name of the job to be executed.
- wait_minutes - (Optional) The time when the task is scheduled to be attempted.
- base_path - (Reserved)

Other parameters can be freely used in the job.
