'use strict';

const Nodal = require('nodal');
const router = new Nodal.Router();

/* Middleware */
/* executed *before* Controller-specific middleware */

const CORSMiddleware = Nodal.require('middleware/cors_middleware.js');
// const CORSAuthorizationMiddleware = Nodal.require('middleware/cors_authorization_middleware.js');
// const ForceWWWMiddleware = Nodal.require('middleware/force_www_middleware.js');
// const ForceHTTPSMiddleware = Nodal.require('middleware/force_https_middleware.js');

router.middleware.use(CORSMiddleware);
// router.middleware.use(CORSAuthorizationMiddleware);
// router.middleware.use(ForceWWWMiddleware);
// router.middleware.use(ForceHTTPSMiddleware);

/* Renderware */
/* executed *after* Controller-specific renderware */

const GzipRenderware = Nodal.require('renderware/gzip_renderware.js')

router.renderware.use(GzipRenderware);

/* Routes */

const IndexController = Nodal.require('app/controllers/index_controller.js');

/* generator: begin imports */

const V1WinePricesController = Nodal.require('app/controllers/v1/wine_prices_controller.js');
const V1UsersController = Nodal.require('app/controllers/v1/users_controller.js');
const V1ProvenancesController = Nodal.require('app/controllers/v1/provenances_controller.js');
const V1AccessTokensController = Nodal.require('app/controllers/v1/access_tokens_controller.js');
const V1CatalogsController = Nodal.require('app/controllers/v1/catalogs_controller.js');
const V1CatalogsFileController = Nodal.require('app/controllers/v1/catalogs_file_controller.js');
const V1UserAclsController = Nodal.require('app/controllers/v1/user_acls_controller.js');
const V1Controller = Nodal.require('app/controllers/v1_controller.js');
const V1PagesController = Nodal.require('app/controllers/v1/pages_controller.js');

/* generator: end imports */

router.route('/').use(IndexController);

/* generator: begin routes */

router.route('/v1/wine_prices/{id}').use(V1WinePricesController);
router.route('/v1/users/{id}').use(V1UsersController);
router.route('/v1/provenances/{id}').use(V1ProvenancesController);
router.route('/v1/access_tokens/{id}').use(V1AccessTokensController);
router.route('/v1/catalogs/{id}').use(V1CatalogsController);
router.route('/v1/catalogs/{id}/file').use(V1CatalogsFileController);
router.route('/v1/user_acls/{id}').use(V1UserAclsController);
router.route('/v1/{id}').use(V1Controller);
router.route('/v1/pages/{id}').use(V1PagesController);

/* generator: end routes */

module.exports = router;
