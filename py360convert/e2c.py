import gc

import numpy as np
import psutil

from . import utils


def e2c(e_img, face_w=256, mode='bilinear', cube_format='dice'):
    '''
    e_img:  ndarray in shape of [H, W, *]
    face_w: int, the length of each face of the cubemap
    '''
    assert len(e_img.shape) == 3
    h, w = e_img.shape[:2]
    if mode == 'bilinear':
        order = 1
    elif mode == 'nearest':
        order = 0
    else:
        raise NotImplementedError('unknown mode')

    xyz = utils.xyzcube(face_w)
    print("xyzcube ram usage:", psutil.virtual_memory().percent)
    gc.collect()
    print("xyzcube gc ram usage:", psutil.virtual_memory().percent)
    uv = utils.xyz2uv(xyz)

    print("xyz2uv ram usage:", psutil.virtual_memory().percent)
    del xyz
    print("xyzcube del xyz ram usage:", psutil.virtual_memory().percent)
    gc.collect()
    print("xyzcube gc ram usage:", psutil.virtual_memory().percent)
    coor_xy = utils.uv2coor(uv, h, w)

    print("uv2coor ram usage:", psutil.virtual_memory().percent)
    del uv
    print("uv2coor del uv ram usage:", psutil.virtual_memory().percent)
    gc.collect()
    print("uv2coor gc ram usage:", psutil.virtual_memory().percent)

    cubemap = np.stack([
        utils.sample_equirec(e_img[..., i], coor_xy, order=order)
        for i in range(e_img.shape[2])
    ], axis=-1)
    print("cubemap stacking gc ram usage:", psutil.virtual_memory().percent)
    if cube_format == 'horizon':
        pass
    elif cube_format == 'list':
        cubemap = utils.cube_h2list(cubemap)
    elif cube_format == 'dict':
        cubemap = utils.cube_h2dict(cubemap)
    elif cube_format == 'dice':
        cubemap = utils.cube_h2dice(cubemap)
    else:
        raise NotImplementedError()

    return cubemap
