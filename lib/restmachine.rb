require 'treetop'
base_path = File.expand_path(File.dirname(__FILE__))
Treetop.load(File.join(base_path, 'restmachine', 'grammar', 'restmachine_path.treetop'))

require "restmachine/version"
require 'webmachine'
require 'webmachine/actionview'
require 'restmachine/extensions/restmachine_path'
require 'restmachine/extensions/route_parser'
require 'restmachine/extensions/route'
require 'restmachine/extensions/dispatcher'
require 'restmachine/extensions/authentication'
require 'restmachine/errors'
require 'restmachine/application_policy'
require 'restmachine/endpoint'
require 'restmachine/controller'
require 'restmachine/resource/post_action'
require 'restmachine/resource/model'
require 'restmachine/resource/item'
require 'restmachine/resource/collection'
