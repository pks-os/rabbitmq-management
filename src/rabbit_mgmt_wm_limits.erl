%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is RabbitMQ Management Plugin.
%%
%%   The Initial Developer of the Original Code is GoPivotal, Inc.
%%   Copyright (c) 2007-2016 Pivotal Software, Inc.  All rights reserved.
%%

-module(rabbit_mgmt_wm_limits).

-export([init/3, rest_init/2, to_json/2, content_types_provided/2,
         resource_exists/2, is_authorized/2, allowed_methods/2]).
-export([variances/2]).

-include_lib("rabbitmq_management_agent/include/rabbit_mgmt_records.hrl").
-include_lib("rabbit_common/include/rabbit.hrl").

%%--------------------------------------------------------------------

init(_, _, _) -> {upgrade, protocol, cowboy_rest}.

rest_init(Req, _Config) ->
    {ok, rabbit_mgmt_cors:set_headers(Req, ?MODULE), #context{}}.

variances(Req, Context) ->
    {[<<"accept-encoding">>, <<"origin">>], Req, Context}.

allowed_methods(ReqData, Context) ->
    {[<<"GET">>, <<"PUT">>, <<"OPTIONS">>], ReqData, Context}.

%% Admin user can see all vhosts

is_authorized(ReqData, Context) ->
    rabbit_mgmt_util:is_authorized_vhost_visible(ReqData, Context).

content_types_provided(ReqData, Context) ->
   {[{<<"application/json">>, to_json}], ReqData, Context}.

resource_exists(ReqData, Context) ->
    {case rabbit_mgmt_util:vhost(ReqData) of
         not_found -> false;
         _         -> true
     end, ReqData, Context}.

to_json(ReqData, Context) ->
    rabbit_mgmt_util:reply_list(limits(ReqData, Context), [], ReqData, Context).

limits(ReqData, Context) ->
    case rabbit_mgmt_util:vhost(ReqData) of
        none ->
            User = Context#context.user,
            VisibleVhosts = rabbit_mgmt_util:list_visible_vhosts(User),
            [ [{vhost, VHost}, {value, Value}]
              || {VHost, Value} <- rabbit_vhost_limit:list(),
                 lists:member(VHost, VisibleVhosts) ];
        VHost when is_binary(VHost) ->
            [ [{vhost, AVHost}, {value, Value}]
	      || {AVHost, Value} <- rabbit_vhost_limit:list(VHost)]
    end.
%%--------------------------------------------------------------------

