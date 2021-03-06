Mesh.Algorithm = 5;

Function MakeVolume
  // Arguments
  // ---------
  //   volume_surfaces
  //      Surfaces[]
  // Returns
  // -------
  //   volume
  //      Volume
  _volume_loop = newsl;
  Surface Loop(_volume_loop) = volume_surfaces[];
  volume = newv;
  Volume(volume) = _volume_loop;
Return


Function MakeSphericalCap
  // Arguments
  // ---------
  //   cap_center, cap_top, cap_nodes[]
  //      Point
  //   cap_arcs[]
  //      Circle
  // Returns
  // -------
  //   cap_surfaces[]
  //      Surface

  _n = # cap_nodes[];
  For _i In {0: _n - 1}
    _cap_radii[_i] = newl;
    Circle(_cap_radii[_i]) = {cap_nodes[_i], cap_center, cap_top};
  EndFor

  For _i In {0: _n - 1}
    _loop = newll;
    _surface = news;

    Line Loop(_loop) = {-_cap_radii[_i],
                        cap_arcs[_i],
                        _cap_radii[(_i+1) % _n]};
    Surface(_surface) = {_loop};

    cap_surfaces[_i] = _surface;
  EndFor
Return


Function MakeSphericalSegment
  // Arguments
  // ---------
  //   segment_center, segment_upper_nodes[], segment_lower_nodes[]
  //      Point
  //   segment_upper_arcs[], segment_lower_arcs[]
  //      Circle
  // Returns
  // -------
  //   segment_surfaces[]
  //      Surface

  _n = # segment_upper_nodes[];
  For _i In {0: _n - 1}
    _meridians[_i] = newl;
    Circle(_meridians[_i]) = {segment_lower_nodes[_i],
                              segment_center,
                              segment_upper_nodes[_i]};
  EndFor

  For _i In {0: _n - 1}
    _loop = newll;
    _surface = news;

    Line Loop(_loop) = {segment_lower_arcs[_i],
                        _meridians[(_i + 1) % _n],
                        -segment_upper_arcs[_i],
                        -_meridians[_i]};
    Surface(_surface) = {_loop};

    segment_surfaces[_i] = _surface;
  EndFor
Return


Function MakeHorizontalCircle
  // Arguments
  // ---------
  //   z, y, z, r, element_length
  //      float
  //   n_meridians
  //      int
  // Returns
  // -------
  //   circle_center, circle_nodes[]
  //      Point
  //   circle_arcs[]
  //      Circle
  //   circle_radii[]
  //      Line
  //   circle_surfaces[]
  //      Surface

  circle_center = newp;
  Point(circle_center) = {x, y, z, element_length};
  Call MakeNodesOfHorizontalCircle;
  Call MakeCircleArcs;
  Call MakeCircleSurface;
Return


Function MakeNodesOfHorizontalCircle
  // Arguments
  // ---------
  //   z, y, z, r, element_length
  //      float
  //   n_meridians
  //      int
  // Returns
  // -------
  //   circle_nodes[]
  //      Point
  
  For _i In {0: n_meridians - 1}
    _point = newp;

    _arc = 2 * Pi * _i / n_meridians;
    Point(_point) =  {x + r * Sin(_arc),
                      y + r * Cos(_arc),
                      z,
                      element_length};

     circle_nodes[_i] = _point;
  EndFor
Return


Function MakeCircleArcs
  // Arguments
  // ---------
  //   circle_center, circle_nodes[]
  //      Point
  // Returns
  // -------
  //   circle_arcs[]
  //      Circle

  _n = # circle_nodes[];
  For _i In {0: _n - 1}
    _arc = newl;
    circle_arcs[_i] = _arc;
    Circle(_arc) = {circle_nodes[_i],
                    circle_center,
                    circle_nodes[(_i + 1) % _n]};
  EndFor
Return


Function MakeCircleSurface
  // Arguments
  // ---------
  //   circle_center, circle_nodes[]
  //      Point
  //   circle_arcs[]
  //      Circle
  // Returns
  // -------
  //   circle_radii[]
  //      Line
  //   circle_surfaces[]
  //      Surface

  _n = # circle_nodes[];
  For _i In {0: _n - 1}
    _arc = newl;
    circle_radii[_i] = _arc;
    Line(_arc) = {circle_nodes[_i],
                  circle_center};
  EndFor

  For _i In {0: _n - 1}
    _loop = newll;
    _surface = news;

    Line Loop(_loop) = {-circle_radii[_i],
                        circle_arcs[_i],
                        circle_radii[(_i + 1) % _n]};
    Surface(_surface) = {_loop};

    circle_surfaces[_i] = _surface;
  EndFor
Return


Function MakeRingSurface
  // Arguments
  // ---------
  //   ring_a_nodes[], ring_b_nodes[]
  //      Point
  //   ring_a_arcs[], ring_b_arcs[]
  //      Circle
  // Returns
  // -------
  //   ring_surfaces
  //      Surface[]

  _n = # ring_a_nodes[];
  For _i In {0: _n - 1}
    _meridians[_i] = newl;
    Line(_meridians[_i]) = {ring_b_nodes[_i],
                            ring_a_nodes[_i]};
  EndFor

  For _i In {0: _n - 1}
    _loop = newll;
    _surface = news;

    Line Loop(_loop) = {ring_b_arcs[_i],
                        _meridians[(_i + 1) % _n],
                        -ring_a_arcs[_i],
                        -_meridians[_i]};
    Surface(_surface) = {_loop};

    ring_surfaces[_i] = _surface;
  EndFor
Return


Function MakeRoiLayer
  // Arguments
  // ---------
  //   layer_no, n_meridians
  //     int
  //   x, y, r, h, roi_element_length, roi_layer_h_factor[], roi_element_length_layer_factor[]
  //     float
  // Returns
  // -------
  //   roi_layer_center, roi_layer_nodes[]
  //      Point
  //   roi_layer_arcs[]
  //      Circle
  //   roi_layer_surfaces[]
  //      Surface
  // Alters
  // ------
  //   z, element_length, circle_center, circle_nodes[], circle_arcs[],
  //   circle_radii[], circle_surfaces[]

  z = roi_layer_h_factor[layer_no] * h;
  element_length = roi_element_length_layer_factor[layer_no] * roi_element_length;

  Call MakeHorizontalCircle;

  roi_layer_center = circle_center;
  roi_layer_nodes[] = circle_nodes[];
  roi_layer_arcs[] = circle_arcs[];
  roi_layer_surfaces[] = circle_surfaces[];
Return

n_meridians = 6;

h = 0.0003;
roi_r = 0.0003;
slice_r = 0.003;
saline_r = 0.1;

roi_element_length = h * 0.25 * 1;
roi_element_length_layer_factor = {0.125,
                                   0.5,
                                   1,
                                   1,
                                   0.5,
                                   0.125};
roi_layer_h_factor = {0.00,
                      0.22,
                      0.33,
                      0.66,
                      0.88,
                      1.00};
roi_cap_element_length = h * 0.5 * 1;
slice_element_length = h * 1;
slice_cap_element_length = 2 * h * 1;
saline_element_length = 0.05 * 1;

x = 0.; y = 0.;
r = roi_r;

roi_volumes[] = {};
roi_side_surfaces[] = {};
layer_no = 0;

Call MakeRoiLayer;

lower_center = roi_layer_center;
roi_lower_nodes[] = roi_layer_nodes[];
roi_lower_arcs[] = roi_layer_arcs[];
roi_lower_surfaces[] = roi_layer_surfaces[];

upper_center = roi_layer_center;
roi_upper_nodes[] = roi_layer_nodes[];
roi_upper_arcs[] = roi_layer_arcs[];
roi_upper_surfaces[] = roi_layer_surfaces[];

n_roi_layers = # roi_layer_h_factor[];

For layer_no In {1: n_roi_layers - 1}
  Call MakeRoiLayer;

  ring_a_nodes[] = roi_layer_nodes[];
  ring_a_arcs[] = roi_layer_arcs[];
  ring_b_nodes[] = roi_upper_nodes[];
  ring_b_arcs[] = roi_upper_arcs[];

  Call MakeRingSurface;
  roi_side_surfaces[] = {roi_side_surfaces[],
                         ring_surfaces[]};

  volume_surfaces[] = {ring_surfaces[],
                       roi_layer_surfaces[],
                       roi_upper_surfaces[]};

  Call MakeVolume;
  roi_volumes[] = {roi_volumes[], volume};

  upper_center = roi_layer_center;
  roi_upper_nodes[] = roi_layer_nodes[];
  roi_upper_arcs[] = roi_layer_arcs[];
  roi_upper_surfaces[] = roi_layer_surfaces[];
EndFor


cap_center = upper_center;
cap_top = newp;
Point(cap_top) = {x, y, z + r, roi_cap_element_length};
cap_nodes[] = roi_upper_nodes[];
cap_arcs[] = roi_upper_arcs[];
Call MakeSphericalCap;
roi_cap_surfaces[] = cap_surfaces[];

volume_surfaces[] = {roi_upper_surfaces[],
                     roi_cap_surfaces[]};
Call MakeVolume;
roi_cap_volume = volume;

z = 0;
r = slice_r;
element_length = slice_element_length;
Call MakeNodesOfHorizontalCircle;
circle_center = lower_center;
Call MakeCircleArcs;
slice_lower_nodes[] = circle_nodes[];
slice_lower_arcs[] = circle_arcs[];

ring_a_nodes[] = slice_lower_nodes[];
ring_a_arcs[] = slice_lower_arcs[];
ring_b_nodes[] = roi_lower_nodes[];
ring_b_arcs[] = roi_lower_arcs[];
Call MakeRingSurface;
slice_lower_surfaces[] = ring_surfaces[];

z = h;
r = slice_r;
element_length = slice_element_length;
Call MakeNodesOfHorizontalCircle;
circle_center = upper_center;
Call MakeCircleArcs;
slice_upper_nodes[] = circle_nodes[];
slice_upper_arcs[] = circle_arcs[];

ring_a_nodes[] = slice_upper_nodes[];
ring_a_arcs[] = slice_upper_arcs[];
ring_b_nodes[] = roi_upper_nodes[];
ring_b_arcs[] = roi_upper_arcs[];
Call MakeRingSurface;
slice_upper_surfaces[] = ring_surfaces[];

ring_a_nodes[] = slice_upper_nodes[];
ring_a_arcs[] = slice_upper_arcs[];
ring_b_nodes[] = slice_lower_nodes[];
ring_b_arcs[] = slice_lower_arcs[];
Call MakeRingSurface;
slice_external_surfaces[] = ring_surfaces[];

volume_surfaces[] = {roi_side_surfaces[],
                     slice_lower_surfaces[],
                     slice_upper_surfaces[],
                     slice_external_surfaces[]};
Call MakeVolume;
surrounding_slice_volume = volume;


cap_center = upper_center;
cap_top = newp;
Point(cap_top) = {x, y, z + r, slice_cap_element_length};
cap_nodes[] = slice_upper_nodes[];
cap_arcs[] = slice_upper_arcs[];
Call MakeSphericalCap;
slice_cap_surfaces[] = cap_surfaces[];

volume_surfaces[] = {slice_upper_surfaces[],
                     slice_cap_surfaces[],
                     roi_cap_surfaces[]};
Call MakeVolume;
slice_cap_volume = volume;


z = 0;
r = saline_r;
element_length = saline_element_length;
Call MakeNodesOfHorizontalCircle;
circle_center = lower_center;
Call MakeCircleArcs;
saline_lower_nodes[] = circle_nodes[];
saline_lower_arcs[] = circle_arcs[];

ring_a_nodes[] = saline_lower_nodes[];
ring_a_arcs[] = saline_lower_arcs[];
ring_b_nodes[] = slice_lower_nodes[];
ring_b_arcs[] = slice_lower_arcs[];
Call MakeRingSurface;
saline_base_surfaces[] = ring_surfaces[];

cap_center = lower_center;
cap_top = newp;
Point(cap_top) = {x, y, r, saline_element_length};
cap_nodes[] = saline_lower_nodes[];
cap_arcs[] = saline_lower_arcs[];
Call MakeSphericalCap;
saline_cap_surfaces[] = cap_surfaces[];

volume_surfaces[] = {slice_cap_surfaces[],
                     saline_base_surfaces[],
                     slice_external_surfaces[],
                     saline_cap_surfaces[]};
Call MakeVolume;
saline_cap_volume = volume;

Physical Volume ("slice") = {roi_volumes[],
                             surrounding_slice_volume};
Physical Volume ("saline") = {roi_cap_volume,
                              slice_cap_volume,
                              saline_cap_volume};
Physical Surface ("dome") = saline_cap_surfaces[];
Physical Surface ("slice_base") = {roi_lower_surfaces[],
                                   slice_lower_surfaces[]};
Physical Surface ("saline_base") = saline_base_surfaces[];
