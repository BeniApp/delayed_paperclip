Delayed::Paperclip 

This is a fork from [Delayed::Paperclip](https://github.com/jstorimer/delayed_paperclip) that allows attachments using [Papercrop](https://github.com/rsantamaria/papercrop) to be processed in the background using [Delayed::Job](https://github.com/collectiveidea/delayed_job)

It's important to note that even though the original Delayed::Paperclip works with Resque, ActiveJob and Sidekiq, this fork only supports Delayed::Job as the background queue.

DelayedPaperclip lets you process your [Paperclip](http://github.com/thoughtbot/paperclip) attachments in a
background task with [DelayedJob](https://github.com/collectiveidea/delayed_job), [Resque](https://github.com/resque/resque) or [Sidekiq](https://github.com/mperham/sidekiq).

Installation
------------

Install the gem:

````
gem 'delayed_paperclip', path: 'https://github.com/BeniApp/delayed_paperclip'
````

Dependencies:

-   Paperclip v4.1.1
-   DJ v4.0.4
-   Papercrop v0.2.0

Usage
-----

In your model:

````ruby
class User < ActiveRecord::Base
  include DelayedPaperclip::CropModelExtension

  has_attached_file :avatar, styles: {
                                       medium: "300x300>",
                                       thumb: "100x100>"
                                     }

  process_in_background :avatar
  keep_crop_attributes :avatar
end
````