serpent = (loadfile "serpent.lua")()
redis = (loadfile "lua-redis.lua")()
database = Redis.connect('127.0.0.1', 6379)
chats = {}
day = 86400
bot_id = 322190322 -- Your Bot USER_ID
sudo_users = {274807882}
  -----------------------------------------------------------------------------------------------
                                     -- start functions --
  -----------------------------------------------------------------------------------------------
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
-----------------------------------------------------------------------------------------------
function is_admin(user_id)
    local var = false
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	 if admin then
	    var = true
	 end
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_vip_group(gp_id)
    local var = false
	local hashs =  'bot:vipgp:'
    local vip = database:sismember(hashs, gp_id)
	 if vip then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_owner(user_id, chat_id)
    local var = false
    local hash =  'bot:owners:'..chat_id
    local owner = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
    return var
end
-----------------------------------------------------------------------------------------------
function is_mod(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
    return var
end
-----------------------------------------------------------------------------------------------
function is_banned(user_id, chat_id)
    local var = false
	local hash = 'bot:banned:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_muted(user_id, chat_id)
    local var = false
	local hash = 'bot:muted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_gbanned(user_id)
    local var = false
	local hash = 'bot:gbanned:'
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
  -----------------------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
  -----------------------------------------------------------------------------------------------
function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end
  -----------------------------------------------------------------------------------------------
function chat_leave(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Left")
end
  -----------------------------------------------------------------------------------------------
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
end
  -----------------------------------------------------------------------------------------------
local function getParseMode(parse_mode)  
  if parse_mode then
    local mode = parse_mode:lower()
  
    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  return P
end
  -----------------------------------------------------------------------------------------------
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUserFull(user_id,cb)
  tdcli_function ({
    ID = "GetUserFull",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
-----------------------------------------------------------------------------------------------
function dl_cb(arg, data)
end
-----------------------------------------------------------------------------------------------
local function send(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function changetitle(chat_id, title)
  tdcli_function ({
    ID = "ChangeChatTitle",
    chat_id_ = chat_id,
    title_ = title
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function edit(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function setphoto(chat_id, photo)
  tdcli_function ({
    ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
    photo_ = getInputFile(photo)
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function add_user(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit or 50
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function unpinmsg(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delete_msg(chatid,mid)
  tdcli_function ({
  ID="DeleteMessages", 
  chat_id_=chatid, 
  message_ids_=mid
  },
  dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function chat_del_user(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, 'Editor')
end
-----------------------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit)
  if not limit or limit > 200 then
    limit = 200
  end
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getChannelFull(channel_id)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function getInputMessageContent(file, filetype, caption)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  local inmsg = {}
  local filetype = filetype:lower()

  if filetype == 'animation' then
    inmsg = {ID = "InputMessageAnimation", animation_ = infile, caption_ = caption}
  elseif filetype == 'audio' then
    inmsg = {ID = "InputMessageAudio", audio_ = infile, caption_ = caption}
  elseif filetype == 'document' then
    inmsg = {ID = "InputMessageDocument", document_ = infile, caption_ = caption}
  elseif filetype == 'photo' then
    inmsg = {ID = "InputMessagePhoto", photo_ = infile, caption_ = caption}
  elseif filetype == 'sticker' then
    inmsg = {ID = "InputMessageSticker", sticker_ = infile, caption_ = caption}
  elseif filetype == 'video' then
    inmsg = {ID = "InputMessageVideo", video_ = infile, caption_ = caption}
  elseif filetype == 'voice' then
    inmsg = {ID = "InputMessageVoice", voice_ = infile, caption_ = caption}
  end

  return inmsg
end

-----------------------------------------------------------------------------------------------
function send_file(chat_id, type, file, caption,wtf)
local mame = (wtf or 0)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = mame,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUser(user_id, cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
------------------------------------------------------------------------------------------------
local function sendDocument(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, document, caption, dl_cb, cmd)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageDocument",
      document_ = getInputFile(document),
      --thumb_ = {
        --ID = "InputThumb",
        --path_ = path,
        --width_ = width,
        --height_ = height
      --},
      caption_ = caption
    },
  }, dl_cb, cmd)
end
-----------------------------------------------------------------------------------------------
function tdcli_update_callback(data)
	-------------------------------------------
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    --vardump(data)
    local d = data.disable_notification_
    local chat = chats[msg.chat_id_]
	-------------------------------------------
	if msg.date_ < (os.time() - 30) then
       return false
    end
	-------------------------------------------
	if not database:get("bot:enable:"..msg.chat_id_) and not is_admin(msg.sender_user_id_, msg.chat_id_) then
      return false
    end
    -------------------------------------------
      if msg and msg.send_state_.ID == "MessageIsSuccessfullySent" then
	  --vardump(msg)
	   function get_mymsg_contact(extra, result, success)
             --vardump(result)
       end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,get_mymsg_contact)
         return false 
      end
    --------- ANTI FLOOD -------------------
	local hash = 'flood:max:'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 5
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 3
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_mod(msg.sender_user_id_, msg.chat_id_)
         and not is msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
        local hashse = 'anti-flood:'..msg.chat_id_
        if not database:get(hashse) then
                if not is_mod(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:banned:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, '> _ID_  *('..msg.sender_user_id_..')* \n_Spamming Not Allowed Here._\n`Spammer Banned!!`', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	-------------------------------------------
	database:incr("bot:allmsgs")
	if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
        elseif id:match('^(%d+)') then
        if not database:sismember("bot:userss",msg.chat_id_) then
            database:sadd("bot:userss",msg.chat_id_)
        end
        else
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
     end
    end
	-------------------------------------------
    -------------* MSG TYPES *-----------------
   if msg.content_ then
   	if msg.reply_markup_ and  msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" then
		print("INLINE KEYBOARD DETECTED!!")
	msg_type = 'MSG:Inline'
	-------------------------
    elseif msg.content_.ID == "MessageText" then
	text = msg.content_.text_
		print("TEXT MSG DETECTED!!")
	msg_type = 'MSG:Text'
	-------------------------
	elseif msg.content_.ID == "MessagePhoto" then
	print("PHOTO DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Photo'
	-------------------------
	elseif msg.content_.ID == "MessageChatAddMembers" then
	print("NEW ADD DETECTED!!")
	msg_type = 'MSG:NewUserAdd'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" then
		print("NEW JOIN DETECTED!!")
	msg_type = 'MSG:NewUserLink'
	-------------------------
	elseif msg.content_.ID == "MessageSticker" then
		print("STICKER DETECTED!!")
	msg_type = 'MSG:Sticker'
	-------------------------
	elseif msg.content_.ID == "MessageAudio" then
		print("MUSIC DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Audio'
	-------------------------
	elseif msg.content_.ID == "MessageVoice" then
		print("VOICE DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Voice'
	-------------------------
	elseif msg.content_.ID == "MessageVideo" then
		print("VIDEO DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Video'
	-------------------------
	elseif msg.content_.ID == "MessageAnimation" then
		print("GIF DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Gif'
	-------------------------
	elseif msg.content_.ID == "MessageLocation" then
		print("LOCATION DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Location'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
	msg_type = 'MSG:NewUser'
	-------------------------
	elseif msg.content_.ID == "MessageContact" then
		print("CONTACT DETECTED!!")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Contact'
	-------------------------
	end
   end
  -----------------------------------------------------------------------------------------------
                                     -- end functions --
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                                     -- start code --
  -----------------------------------------------------------------------------------------------
  -------------------------------------- Process mod --------------------------------------------
  -----------------------------------------------------------------------------------------------
  
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  --------------------------******** START MSG CHECKS ********-------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
if is_banned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
		  return 
end
if is_muted(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
          delete_msg(chat,msgs)
		  return 
end
if is_gbanned(msg.sender_user_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
		   return 
end	
if database:get('bot:muteall'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        return 
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:mute'..msg.chat_id_) then
   send(msg.chat_id_, msg.id_, 1, 'شما دسترسی به این کار را ندارید...\nمن پیام شما را آنپین و در صورت در دسترس بودن پیام قبل رو دوباره پین میکنم...\nدر صورتی که در ربات مقامی دارید میتوانید با ریپلی کردن پیام و ارسال دستور /pin پیام جدید رو برای پین شدن تنظیم کنید!', 1, 'md')
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
if database:get('bot:viewget'..msg.sender_user_id_) then 
    if not msg.forward_info_ then
		send(msg.chat_id_, msg.id_, 1, '*Error*\n`Please send this command again and forward your post(from channel)`', 1, 'md')
		database:del('bot:viewget'..msg.sender_user_id_)
	else
		send(msg.chat_id_, msg.id_, 1, 'Your Post Views:\n> '..msg.views_..' View!', 1, 'md')
        database:del('bot:viewget'..msg.sender_user_id_)
	end
end
if msg_type == 'MSG:Photo' then
   --vardump(msg)
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
     if database:get('bot:photo:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   if caption_text then
      
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
  elseif msg_type == 'MSG:Inline' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:inline:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   end
  elseif msg_type == 'MSG:Sticker' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:sticker:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   end
elseif msg_type == 'MSG:NewUserLink' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   function get_welcome(extra,result,success)
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = '*Hi {firstname} 😃*'
    end
    local text = text:gsub('{firstname}',(result.first_name_ or ''))
    local text = text:gsub('{lastname}',(result.last_name_ or ''))
    local text = text:gsub('{username}',(result.username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
	  if database:get("bot:welcome"..msg.chat_id_) then
        getUser(msg.sender_user_id_,get_welcome)
      end
elseif msg_type == 'MSG:NewUserAdd' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
      --vardump(msg)
   if msg.content_.members_[0].username_ and msg.content_.members_[0].username_:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
	  end
   end
   if is_banned(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
   end
   if database:get("bot:welcome"..msg.chat_id_) then
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = '*Hi {firstname} 😃*'
    end
    local text = text:gsub('{firstname}',(msg.content_.members_[0].first_name_ or ''))
    local text = text:gsub('{lastname}',(msg.content_.members_[0].last_name_ or ''))
    local text = text:gsub('{username}',('@'..msg.content_.members_[0].username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
elseif msg_type == 'MSG:Contact' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:contact:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   end
elseif msg_type == 'MSG:Audio' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:music:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   if caption_text then
      
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
 if caption_text:match("@") or msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
  	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
     if caption_text:match("[\216-\219][\128-\191]") then
    if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Voice' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:voice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
   if caption_text then
      
  if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
  if caption_text:match("@") then
  if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	 if caption_text:match("[\216-\219][\128-\191]") then
    if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Location' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:location:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
   if caption_text then
      
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Video' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:video:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
   if caption_text then
      
  if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Gif' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:gifs:mute'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
   if caption_text then
   
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end	
   end
elseif msg_type == 'MSG:Text' then
 --vardump(msg)
    if database:get("bot:group:link"..msg.chat_id_) == 'Waiting For Link!\nPls Send Group Link.\n\nJoin My Channel > @Black_Ch' and is_mod(msg.sender_user_id_, msg.chat_id_) then
      if text:match("(https://telegram.me/joinchat/%S+)") then
	  local glink = text:match("(https://telegram.me/joinchat/%S+)")
      local hash = "bot:group:link"..msg.chat_id_
               database:set(hash,glink)
			  send(msg.chat_id_, msg.id_, 1, '*New link Set!*', 1, 'md')
			  send(msg.chat_id_, 0, 1, '<b>New Group link:</b>\n'..glink, 1, 'html')
      end
   end
    function check_username(extra,result,success)
	 --vardump(result)
	local username = (result.username_ or '')
	local svuser = 'user:'..result.id_
	if username then
      database:hset(svuser, 'username', username)
    end
	if username and username:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(result.id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, result.id_)
		 return false
		 end
	  end
   end
    getUser(msg.sender_user_id_,check_username)
   database:set('bot:editid'.. msg.id_,msg.content_.text_)
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
	if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
     if database:get('bot:links:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if text then
     if database:get('bot:text:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   if text:match("@") or msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("#") then
      if database:get('bot:hashtag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
      if database:get('bot:webpage:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("[\216-\219][\128-\191]") then
      if database:get('bot:arabic:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	  if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
      if database:get('bot:english:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	  end
     end
    end
   end
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  ---------------------------******** END MSG CHECKS ********--------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  if text:match("^[!/#]ping$") then
      sendDocument(msg.chat_id_, msg.id_, 0, 1, nil, './ping.gif', 'Powered By @Secure_Channel', dl_cb, nil)]
end
-----------------------------------------------------------------------------------------------------------
        if text:match("^[Ss]etlang (.*)$") or text:match("^تنظیم زبان (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          local langs = {string.match(text, "^(.*) (.*)$")}
          if langs[2] == "fa" or langs[2] == "فارسی" then
            if not database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> زبان ربات هم اکنون بر روی فارسی قرار دارد !', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> زبان ربات به فارسی تغییر پیدا کرد ! ', 1, 'md')
              database:del('lang:gp:'..msg.chat_id_)
            end
          end
          if langs[2] == "en" or langs[2] == "انگلیسی" then
            if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, '> Language Bot is *already* English', 1, 'md')
            else
              send(msg.chat_id_, msg.id_, 1, '> Language Bot has been changed to *English* !', 1, 'md')
              database:set('lang:gp:'..msg.chat_id_,true)
            end
          end
        end
		
		if text:match("^[Ss]ettings$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
		     if database:get('lang:gp'..msg.chat_id_) then
			        send(msg.chat_id_, msg.id_, 1, 'bye', 1, 'md')
				else
				   send(msg.chat_id_, msg.id_, 1, 'بای', 1, 'md')
		end
		end
		end
		end
		end
		
