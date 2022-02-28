local subscription = {
    publish = function(serviceId, methodId, value)
        box.session.push({ serviceId, methodId, value })
    end
}
return subscription
