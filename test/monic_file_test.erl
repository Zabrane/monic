%% Copyright 2011 Cloudant
%%
%% Licensed under the Apache License, Version 2.0 (the "License"); you may not
%% use this file except in compliance with the License. You may obtain a copy of
%% the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
%% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
%% License for the specific language governing permissions and limitations under
%% the License.

-module(monic_file_test).
-include("monic.hrl").
-include_lib("eunit/include/eunit.hrl").

all_test_() ->
    {foreach,
    fun setup/0,
    fun cleanup/1,
    [fun add/1,
    fun add_read/1,
    fun add_multi/1,
    fun overflow/1
    ]}.

setup() ->
    file:delete("foo.monic"),
    file:delete("foo.monic.idx"),
    {ok, Pid} = monic_file:open("foo.monic"),
    Pid.

cleanup(Pid) ->
    monic_file:close(Pid).

add(Pid) ->
    ?_assertMatch({ok, 0, _}, monic_file:add(Pid, 3, fun(_Max) -> {ok, <<"123">>} end)).

add_read(Pid) ->
    {ok, Key, Cookie} = monic_file:add(Pid, 3, fun(_Max) -> {ok, <<"123">>} end),
    ?_assertEqual(ok, monic_file:read(Pid, Key, Cookie, fun({ok, <<"123">>}) -> ok end)).

add_multi(Pid) ->
    [?_assertMatch({ok, 0, _}, monic_file:add(Pid, 3, fun(_Max) -> {ok, <<"123">>} end)),
    ?_assertMatch({ok, 1, _}, monic_file:add(Pid, 3, fun(_Max) -> {ok, <<"456">>} end)),
    ?_assertMatch({ok, 2, _}, monic_file:add(Pid, 3, fun(_Max) -> {ok, <<"789">>} end)),
    ?_assertMatch({ok, 3, _}, monic_file:add(Pid, 3, fun(_Max) -> {ok, <<"abc">>} end))].

overflow(Pid) ->
    Res = monic_file:add(Pid, 3, fun(_Max) -> {ok, <<"1234">>} end),
    ?_assertEqual({error, overflow}, Res).