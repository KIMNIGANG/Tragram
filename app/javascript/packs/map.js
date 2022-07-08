"use strict";

Object.defineProperty(exports, "__esModule", { value: true });

const place_geo = [];

// var markers = [];
// var map;

document.getElementById("place-btn").onclick = () => {
  place_geo.forEach((t) => {
    const place_list = document.getElementById("place-list");
    let str = document.createElement("li");
    str.innerHTML = `lat: ${t.lat}, lng: ${t.lng}, name: ${t.name}`;
    place_list.appendChild(str);
  });
};

function initAutocomplete() {
  const map = new google.maps.Map(document.getElementById("map"), {
    center: { lat: 36.0847492, lng: 140.1037952 },
    zoom: 14,
    mapTypeId: "roadmap",
  });

  document.getElementById("set-pin").addEventListener("click", () => {
    place_geo.forEach(function (t) {
      console.log(t.lat);
      markers.push(
        new google.maps.Marker({
          map: map,
          icon: "https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png",
          title: t.name,
          position: { lat: t.lat, lng: t.lng },
          animation: google.maps.Animation.DROP,
        })
      );
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
        url: place.icon, //ここをinstagramの写真のurlに交換することで、写真をピンとして使える
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
      place_geo.push({
        lat: place.geometry["location"].lat(),
        lng: place.geometry["location"].lng(),
        name: place.name,
      });
    });
    map.fitBounds(bounds);
  });
}
window.initAutocomplete = initAutocomplete;
