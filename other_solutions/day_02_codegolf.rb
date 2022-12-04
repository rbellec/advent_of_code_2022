D=$<.map &:bytes;def f =p D.sum{(4*_3-739+6*_1)%9+1};f;D.map!{[_1,0,(_1+_3-1)%3+88]};f


# decomposition
D= $<.map(&:bytes)
def f = p D.sum{ (4 * _3 - 739 + 6 * _1) % 9 + 1 }
f
D.map!{[_1,0,(_1+_3-1)%3+88]}
f
