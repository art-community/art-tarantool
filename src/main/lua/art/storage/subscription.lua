local subscription = {
    publish = function(serviceId, methodId, value)
        local request = {}
        request[0x1] = serviceId
        request[0x2] = methodId
        request[0x3] = value
        box.session.push(request)
    end
}
return subscription
