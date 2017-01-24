'use strict';

const _ = require('lodash');
const Nodal = require('nodal');
const Page = Nodal.require('app/models/page.js');
const AuthController=Nodal.require('app/controllers/auth_controller.js');

const project= {
  default:["id","created_date","updated_date"
          ],
  full:["id",
        "created_date","updated_date",
        {catalog:["id","title"]}
       ],
};

class V1PagesController extends AuthController {

  index() {

    Page.query()
      .where(this.params.query)
      .end((err, models) => {

        this.respond(err || models);

      });

  }

  show() {

    Page.find(this.params.route.id, (err, model) => {

      this.respond(err || model);

    });

  }

  create() {
    this.is_admin( ( accessToken, user ) => {
      let image=this.params.body.image;
      let thumbnail=this.params.body.thumbnail;

      let data=_.omit(this.params.body,['image','thumbnail']);

      data.image_contenttype=image.contentType;
      data.image=image;

      data.thumbnail_contenttype=thumbnail.contentType;
      data.thumbnail=thumbnail;

      Page.create(data, (err, model) => {
        if (err) { this.respond(err) }
          this.respond(model,project.default);
      });
    });
  }

  update() {
    this.is_admin( ( accessToken, user ) => {
      let image=this.params.body.image;
      let thumbnail=this.params.body.thumbnail;

      let data=_.omit(this.params.body,['image','thumbnail']);
      if (image) {
        data.image_contenttype=image.contentType;
        data.image=image;
      }
      if (thumbnail) {
        data.thumbnail_contenttype=thumbnail.contentType;
        data.thumbnail=thumbnail;
      }
      Page.update(this.params.route.id, data,(err, model) => {
        if (err) { this.respond(err) }
          this.respond(model,project.default);
      });
    });
  }

  destroy() {
    this.is_admin( (accessToken, user ) => {
      Page.destroy(this.params.route.id, (err, model) => {
        this.respond(err || model);
      });
    });
  }

}

module.exports = V1PagesController;