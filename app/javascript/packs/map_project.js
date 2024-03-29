"use strict";

Object.defineProperty(exports, "__esModule", { value: true });

const place_geo = [];

// window.onload = function () {};

function initMap() {
  let names = document.getElementsByClassName("loc_name");
  let lats = document.getElementsByClassName("loc_lat");
  let lngs = document.getElementsByClassName("loc_lng");

  console.log(lats[0].value);

  if (lats[0].value == false) {
    place_geo.push({
      lat: 36.0927275,
      lng: 140.0967544,
      name: "tsukuba",
    });
  } else {
    for (let i = 0; i < names.length; i++) {
      place_geo.push({
        lat: lats[i].value,
        lng: lngs[i].value,
        name: names[i].value,
      });
    }
  }

  const map = new google.maps.Map(document.getElementById("map"), {
    center: {
      lat: parseFloat(place_geo[0].lat),
      lng: parseFloat(place_geo[0].lng),
    },
    zoom: 13,
    mapTypeId: "roadmap",
  });

  // console.log(place_geo);

  place_geo.forEach(function (t, i) {
    const marker = new google.maps.Marker({
      position: { lat: parseFloat(t.lat), lng: parseFloat(t.lng) },
      map,
      name: t.name,
      // optimized: false,
    });
    // Add a click listener for each marker, and set up the info window.
    // marker.addListener("click", () => {
    //   location.href = `/posts/${++i}`;
    //   location.replace(link);
    //   window.open(link);
    //   i++;
    // });
  });
}
window.initMap = initMap;
