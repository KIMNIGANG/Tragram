"use strict";

Object.defineProperty(exports, "__esModule", { value: true });

const place_geo = [];
let i = 0;
let j = 0;
// var markers = [];
// var map;

document.getElementById("place-btn").onclick = () => {
  place_geo.forEach(() => {
    const place_list = document.getElementById("place-list");
    let str = document.createElement("li");
    str.innerHTML = `lat: ${place_geo[j].lat}, lng: ${place_geo[j].lng}, name: ${place_geo[j].name}`;
    place_list.appendChild(str);
    j++;
  });
};

// function drop() {
//   clearMarkers();
//   for (var i = 0; i < place_geo.length; i++) {
//     let pos = { lat: place_geo[i].lat, lng: place_geo[i].lng };
//     console.log(pos);
//     addMarkerWithTimeout(pos, i * 200);
//   }
// }

// function addMarkerWithTimeout(position, timeout) {
//   window.setTimeout(function () {
//     markers.push(
//       new google.maps.Marker({
//         position: position,
//         map: map,
//         animation: google.maps.Animation.DROP,
//       })
//     );
//   }, timeout);
// }

// function clearMarkers() {
//   for (var i = 0; i < markers.length; i++) {
//     markers[i].setMap(null);
//   }
//   markers = [];
// }

function initAutocomplete() {
  const map = new google.maps.Map(document.getElementById("map"), {
    center: { lat: 36.0847492, lng: 140.1037952 },
    zoom: 14,
    mapTypeId: "roadmap",
  });
  document.getElementById("clear-pin").addEventListener("click", () => {
    // Clear out the old markers.
    markers.forEach(function (marker) {
      marker.setMap(null);
    });
  });
  // Create the search box and link it to the UI element.
  const input = document.getElementById("pac-input");
  const searchBox = new google.maps.places.SearchBox(input);
  map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);
  // Bias the SearchBox results towards current map's viewport.
  map.addListener("bounds_changed", function () {
    searchBox.setBounds(map.getBounds());
  });
  let markers = [];
  // Listen for the event fired when the user selects a prediction and retrieve
  // more details for that place.
  searchBox.addListener("places_changed", function () {
    var places = searchBox.getPlaces();
    if (places.length == 0) {
      return;
    }
    markers = [];
    // For each place, get the icon, name and location.
    var bounds = new google.maps.LatLngBounds();
    places.forEach(function (place) {
      if (!place.geometry || !place.geometry.location) {
        console.log("Returned place contains no geometry");
        return;
      }
      var icon = {
        url: "https://scontent-nrt1-1.cdninstagram.com/v/t51.29350-15/258823875_270739555103304_3835609014813359582_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=8ae9d6&_nc_ohc=EMPOlnffk1sAX9vd1Ov&_nc_ht=scontent-nrt1-1.cdninstagram.com&edm=ANQ71j8EAAAA&oh=00_AT-crU78purMnEZATrVlk-yCA1IPf6B0J2NOVjKPuUnivA&oe=62C2B1FA",
        size: new google.maps.Size(71, 71),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(17, 34),
        scaledSize: new google.maps.Size(25, 25),
      };
      // ピン　立てる
      markers.push(
        new google.maps.Marker({
          map: map,
          icon: icon,
          title: place.name,
          position: place.geometry.location,
          animation: google.maps.Animation.DROP,
        })
      );
      if (place.geometry.viewport) {
        // Only geocodes have viewport.
        bounds.union(place.geometry.viewport);
      } else {
        bounds.extend(place.geometry.location);
      }
      // 場所のlat,lngをもらってくる
      console.log(place.geometry["location"].lat());
      place_geo[i] = {
        lat: place.geometry["location"].lat(),
        lng: place.geometry["location"].lng(),
        name: place.name,
      };
      console.log(place.geometry["location"].lng());
      i++;
    });
    map.fitBounds(bounds);
  });
}
window.initAutocomplete = initAutocomplete;