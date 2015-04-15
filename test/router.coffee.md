    chai = require 'chai'
    chai.use require 'chai-as-promised'
    chai.should()

    describe 'Router', ->
      Router = require '../router'

      it 'should initialize', ->
        router = new Router()
        router.should.have.property 'cfg'
        router.should.have.property 'session'

      it 'should accept functions as middleware', ->
        router = new Router()
        router.use ->
          @router.session.foo = 'bar'
        router.route data:{}
        .then ->
          router.session.should.have.property 'foo', 'bar'

      it 'should accept modules as middleware', ->
        router = new Router()
        router.use './test/module'
        router.route data:{}
        .then ->
          router.session.should.have.property 'foo', 'bee'
