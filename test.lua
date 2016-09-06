require 'lmdb'


--[[
	txn/cursor put/get test
]]--

local db= lmdb.env{
    Path = './testDB',
    Name = 'testDB'
}

db:open()
print(db:stat()) -- Current status
local num = 1000
local txn = db:txn() --Write transaction
local cursor = txn:cursor()
local x=torch.rand(num,100)

-------Write-------
for i=1,num do
    if i%2 == 0 then
    	cursor:put(i,x[i])
	else
		txn:put(i,x[i])
	end
end
txn:commit()
print(db:stat()) -- Current status

local reader = db:txn(true) --Read-only transaction
local y = torch.Tensor(num,100)

-------Read-------
for i=1,num do
    y[i] = reader:get(i)
end

reader:abort()
print('Difference: ', torch.dist(x,y))
db:close()