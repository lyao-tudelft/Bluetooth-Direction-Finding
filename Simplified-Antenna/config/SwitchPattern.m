classdef SwitchPattern < uint8
    enumeration
        ROUNDROBIN (bi2de([0 0 0 0 0 0 0 0]))
        MIRROR     (bi2de([0 1 0 0 0 0 0 0]))
        RETURNTOFIRST (bi2de([0 0 1 0 0 0 0 0]))
        ARRAY      (bi2de([0 1 1 0 0 0 0 0 ]))
    end
end